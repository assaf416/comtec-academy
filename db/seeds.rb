# Idempotent seed data. Run with: bin/rails db:seed

# --- Admin account (you) ---
admin = User.find_or_initialize_by(email_address: "assaf.g@comtecglobal.com")
admin.assign_attributes(
  name: "אסף",
  role: :admin,
  status: :active,
  activated_at: admin.activated_at || Time.current,
  invited_at: admin.invited_at || Time.current
)
admin.password = ENV.fetch("ADMIN_PASSWORD", "password123") if admin.new_record?
admin.save!
puts "Admin ready: #{admin.email_address} (password: #{ENV.fetch('ADMIN_PASSWORD', 'password123')} unless already set)"

# --- Additional admin ---
gold = User.find_or_initialize_by(email_address: "assaf.goldstein@gmail.com")
gold.assign_attributes(name: "אסף", role: :admin, status: :active,
                       activated_at: gold.activated_at || Time.current,
                       invited_at: gold.invited_at || Time.current)
gold.password = "demo123" if gold.new_record?
gold.save!
puts "Admin ready: #{gold.email_address}"

# --- Non-admin users imported from the Excel roster (with org projects) ---
counts = Users::Importer.import(Rails.root.join("db/seeds/users.xlsx"))
puts "Imported #{counts[:users]} users, #{counts[:memberships]} project memberships"

# --- Sample course with a movie episode and a quiz episode ---
course = Course.find_or_create_by!(name: "יסודות ריאקט") do |c|
  c.details = "קורס מבוא לפיתוח ממשקי משתמש עם React: רכיבים, מצב, ואירועים."
  c.published = true
end

movie = course.episodes.find_or_create_by!(name: "מבוא") do |e|
  e.title = "מבוא לריאקט"
  e.kind = :movie
  e.position = 1
  e.transcript = "בפרק זה נכיר מהו React, למה הוא שימושי, וכיצד בונים רכיב ראשון."
end

quiz = course.episodes.find_or_create_by!(name: "בדיקת ידע") do |e|
  e.title = "בוחן קצר"
  e.kind = :quiz
  e.position = 2
end

quiz.quiz_questions.find_or_create_by!(prompt: "מהו רכיב (component) בריאקט?") do |q|
  q.choices = [ "פונקציה שמחזירה UI", "בסיס נתונים", "שרת HTTP" ]
  q.correct_choice = "פונקציה שמחזירה UI"
end

movie.markdown_docs.find_or_create_by!(name: "סיכום הפרק") do |d|
  d.content = "# סיכום\n\n- **רכיב** הוא פונקציה שמחזירה UI\n- מצב (state) נשמר בתוך הרכיב\n- אפשר להרכיב רכיבים זה בתוך זה\n"
end

puts "Course ready: #{course.name} (#{course.episodes.count} episodes)"

# --- Documents: brand theme + sample project ---
BrandTheme.instance # creates the default company theme if missing

project = Project.find_or_create_by!(slug: "academy-platform") do |p|
  p.name = "פלטפורמת הלמידה"
  p.description = "מסמכי התכנון והתיעוד של אפליקציית האקדמיה."
end
design = project.upsert_document(
  doc_type: :design,
  title: "מסמך עיצוב",
  content: "# מסמך עיצוב\n\nאפליקציית **האקדמיה** לניהול קורסים.\n\n## מטרות\n\n- ניהול קורסים ופרקים\n- הזמנת משתמשים\n- אולפן עריכת וידאו\n"
)
design.update!(tag_list: "תיעוד, עיצוב, אקדמיה")
# Give a couple of documents view counts so the Library "Popular" section is populated.
project.documents.order(:doc_type).each_with_index do |doc, i|
  doc.update_column(:views_count, (project.documents.count - i) * 3)
end

puts "Project ready: #{project.name} (#{project.documents.count} docs)"

# --- Example documents from the documents/ folder (md/html/office -> Library) ---
if Dir.exist?(Rails.root.join("documents"))
  result = Docs::FolderImporter.import(Rails.root.join("documents"))
  puts "Imported #{result[:imported]} example documents into the Library"
end

# --- Presentation layouts (templates) ---
[
  { key: "plain-he", name: "טקסט (עברית)", direction: "rtl", kind: :text,
    description: "שקופית טקסט בעברית",
    css: ".layout-plain-he{background:#fff;color:#1f2937}.layout-plain-he h1,.layout-plain-he h2{color:#1f3a93}" },
  { key: "code-he", name: "קוד (עברית)", direction: "rtl", kind: :code,
    description: "רקע להצגת קוד עם הסבר בעברית",
    css: ".layout-code-he{background:#0f172a;color:#e2e8f0}.layout-code-he h1,.layout-code-he h2{color:#7dd3fc}.layout-code-he pre.code{direction:ltr;text-align:left}" },
  { key: "code-en", name: "קוד (אנגלית)", direction: "ltr", kind: :code,
    description: "Code backdrop, English/LTR",
    css: ".layout-code-en{background:#0f172a;color:#e2e8f0}.layout-code-en h1,.layout-code-en h2{color:#7dd3fc}.layout-code-en pre.code{direction:ltr;text-align:left}" },
  { key: "quiz", name: "בוחן", direction: "rtl", kind: :quiz,
    description: "שקופית שאלה עם אפשרויות בחירה",
    css: ".layout-quiz{background:#fef3c7;color:#78350f}.layout-quiz h1,.layout-quiz h2{color:#b45309}.layout-quiz .choices{list-style:none;padding:0}.layout-quiz .choices li{margin:.4em 0}" }
].each do |attrs|
  layout = Layout.find_or_initialize_by(key: attrs[:key])
  layout.update!(attrs)
end
puts "Layouts ready: #{Layout.count}"

# --- Sample presentation (screenplay -> slides) ---
presentation = Presentation.find_or_create_by!(title: "מבוא ל-Git") do |pr|
  pr.description = "מצגת הדגמה"
  pr.source_md = <<~MD
    # מבוא ל-Git

    שליטה בגרסאות קוד לצוות הפיתוח.

    <!-- note: בשקופית הזו נסביר מהו Git וכיצד הוא עוזר לנו לנהל קוד -->
    ---
    ## פקודות בסיסיות

    ```bash
    git init
    git add .
    git commit -m "first commit"
    ```

    <!-- note: נעבור על שלוש הפקודות הנפוצות ביותר בעבודה היומיומית -->
    ---
    ## בדיקת Cucumber

    ```gherkin
    Feature: התחברות
      Scenario: משתמש מתחבר
        Given משתמש פעיל
    ```

    <!-- note: כך נראית בדיקת קבלה בעברית עם Cucumber -->
  MD
end
presentation.sync_slides!
presentation.update!(status: :ready) # published so it shows in the viewer
puts "Presentation ready: #{presentation.title} (#{presentation.slides.count} slides)"
