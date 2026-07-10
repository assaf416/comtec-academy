LAYOUT_QUIZ_SCREENPLAY = <<~MD.freeze
  # פתיח

  טקסט פתיחה.
  ---
  ## קוד

  ```bash
  git status
  ```

  <!-- layout: code-en -->
  ---
  ## שאלה

  מה עושה git status?

  <!-- quiz
  - מציג שינויים
  - מוחק קבצים
  answer: מציג שינויים
  -->
MD

QUIZ_ONLY_SCREENPLAY = <<~MD.freeze
  # שאלה

  מה עושה git status?

  <!-- quiz
  - מציג שינויים
  - מוחק קבצים
  answer: מציג שינויים
  -->
MD

def ensure_layouts!
  [ %w[plain-he rtl text], %w[code-he rtl code], %w[code-en ltr code], %w[quiz rtl quiz] ].each do |key, dir, kind|
    Layout.find_or_create_by!(key: key) { |l| l.name = key; l.direction = dir; l.kind = kind }
  end
end

def build_presentation(title, source_md, status: :draft)
  ensure_layouts!
  p = Presentation.create!(title: title, source_md: source_md, status: status)
  p.sync_slides!
  p
end

When("I build a presentation with a code-en slide and a quiz slide") do
  @presentation = build_presentation("פריסות", LAYOUT_QUIZ_SCREENPLAY)
end

Then("slide {int} uses layout {string}") do |position, key|
  expect(@presentation.slides.find_by(position: position).layout&.key).to eq(key)
end

Then("the quiz slide has choices and a correct answer") do
  quiz = @presentation.slides.detect(&:quiz?)
  expect(quiz).not_to be_nil
  expect(quiz.choices).to be_present
  expect(quiz.correct_choice).to be_present
end

Given("a published presentation {string}") do |title|
  (@presentations ||= {})[title] = build_presentation(title, "# #{title}\n\nתוכן.", status: :ready)
end

Given("a draft presentation {string}") do |title|
  (@presentations ||= {})[title] = build_presentation(title, "# #{title}\n\nתוכן.", status: :draft)
end

Given("a published presentation with a quiz slide") do
  @presentation = build_presentation("בוחן", QUIZ_ONLY_SCREENPLAY, status: :ready)
end

When("I open the presentations viewer") do
  visit presentations_path
end

Then("I see the presentation {string}") do |title|
  expect(page).to have_content(title)
end

Then("I do not see the presentation {string}") do |title|
  expect(page).to have_no_content(title)
end

When("I open that presentation") do
  visit presentation_path(@presentation)
end

When("I answer the quiz slide with {string}") do |choice|
  choose(choice)
  click_button I18n.t("presentations.submit_answer")
end

Then("my quiz answer is stored and correct") do
  slide = @presentation.slides.detect(&:quiz?)
  answer = SlideAnswer.find_by(user: @current_user, slide: slide)
  expect(answer).not_to be_nil
  expect(answer).to be_correct
end
