SAMPLE_SCREENPLAY = <<~MD.freeze
  # מבוא ל-Git

  שליטה בגרסאות קוד.

  <!-- note: נסביר מהו Git -->
  ---
  ## פקודות

  ```bash
  git init
  git commit -m "x"
  ```

  <!-- note: שלוש הפקודות הנפוצות -->
  ---
  ## סיכום

  נקודות מפתח לזכירה.
MD

When("I create a presentation from the sample screenplay") do
  visit new_admin_presentation_path
  fill_in "presentation_title", with: "מצגת בדיקה"
  fill_in "presentation_source_md", with: SAMPLE_SCREENPLAY
  click_button I18n.t("admin.presentations.save")
  @presentation = Presentation.order(:created_at).last
end

Given("a presentation from the sample screenplay") do
  @presentation = Presentation.create!(title: "מצגת בדיקה", source_md: SAMPLE_SCREENPLAY)
  @presentation.sync_slides!
end

Then("the presentation has {int} slides") do |count|
  expect(@presentation.slides.count).to eq(count)
end

Then("slide {int} is a code slide") do |position|
  expect(@presentation.slides.find_by(position: position)).to be_code
end

Then("slide {int} has narration notes") do |position|
  expect(@presentation.slides.find_by(position: position).notes).to be_present
end

When("the presentation audio is generated") do
  GeneratePresentationAudioJob.perform_now(@presentation)
end

Then("every narrated slide has an audio attachment") do
  narrated = @presentation.slides.select { |s| s.notes.present? }
  expect(narrated).to be_present
  expect(narrated.all? { |s| s.audio.attached? }).to be(true)
end

When("I open the presentation builder") do
  visit admin_presentation_path(@presentation)
end

Then("I see the {int} timeline tracks") do |count|
  expect(page.all(".daw-timeline .daw-track").size).to eq(count)
end

Then("I see the preview stage") do
  expect(page).to have_css(".daw-stage")
end
