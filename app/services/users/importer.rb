require "roo"
require "cgi"
require "securerandom"

module Users
  # Imports non-admin users from the seed .xlsx (first name, last name, projects,
  # email, phone_no), creating projects and memberships and assigning a fake-photo
  # avatar. Idempotent; existing admins are left untouched.
  class Importer
    # Hebrew project names -> stable Latin slugs (parameterize would blank them out).
    PROJECT_SLUGS = {
      "תשתיות" => "tashtiot",
      "חשכל פניסק" => "hashkal-finsk",
      "השחרה להראל" => "hashchara-leharel"
    }.freeze

    def self.import(path)
      new(path).import
    end

    def initialize(path)
      @path = path
    end

    def import
      counts = { users: 0, memberships: 0 }
      rows.each do |row|
        email = row["email"].to_s.strip.downcase
        next if email.blank?

        user = User.find_or_initialize_by(email_address: email)
        next if user.persisted? && user.admin? # never rewrite admin accounts

        counts[:users] += 1 if user.new_record?
        assign_attributes(user, row, email)
        user.save!

        project = find_project(row["projects"])
        if project && !user.project_memberships.exists?(project_id: project.id)
          user.project_memberships.create!(project: project)
          counts[:memberships] += 1
        end
      end
      counts
    end

    private
      def assign_attributes(user, row, email)
        user.name = [ row["first name"], row["last name"] ].map { |v| v.to_s.strip }.reject(&:blank?).join(" ")
        user.phone = row["phone_no"].to_s.strip
        user.role = :student
        user.status = :active
        user.activated_at ||= Time.current
        user.avatar_url = "https://i.pravatar.cc/150?u=#{CGI.escape(email)}"
        user.password = SecureRandom.hex(12) if user.new_record?
      end

      def find_project(name)
        name = name.to_s.strip
        return nil if name.blank?

        Project.find_or_create_by!(name: name) do |p|
          p.slug = PROJECT_SLUGS[name] if PROJECT_SLUGS.key?(name)
        end
      end

      def rows
        Roo::Excelx.new(@path).sheet(0).parse(headers: true).drop(1)
      end
  end
end
