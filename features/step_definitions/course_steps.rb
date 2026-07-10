# --- Course & episode setup ---
Given("a published course {string} with details {string}") do |name, details|
  (@courses ||= {})[name] = Course.create!(name: name, details: details, published: true)
end

Given("the course {string} has a movie episode {string} at position {int}") do |course, title, pos|
  (@episodes ||= {})[title] = @courses.fetch(course).episodes.create!(
    name: title, title: title, kind: :movie, position: pos
  )
end

Given("the course {string} has a quiz episode {string} at position {int}") do |course, title, pos|
  ep = @courses.fetch(course).episodes.create!(name: title, title: title, kind: :quiz, position: pos)
  ep.quiz_questions.create!(prompt: "#{title}?")
  (@episodes ||= {})[title] = ep
end

Given("the course {string} has a movie episode {string} with transcript {string}") do |course, title, transcript|
  (@episodes ||= {})[title] = @courses.fetch(course).episodes.create!(
    name: title, title: title, kind: :movie, transcript: transcript, movie_url: "/sample.mp4"
  )
end

Given("the course {string} has a quiz episode {string} asking {string}") do |course, title, prompt|
  ep = @courses.fetch(course).episodes.create!(name: title, title: title, kind: :quiz)
  ep.quiz_questions.create!(prompt: prompt)
  (@episodes ||= {})[title] = ep
end

# --- Navigation ---
When("I visit the courses page") do
  visit courses_path
end

When("I open the course {string}") do
  visit course_path(@courses.fetch(_1))
end

When("I open the episode {string} in {string}") do |title, course|
  visit course_episode_path(@courses.fetch(course), @episodes.fetch(title))
end

# --- Assertions ---
Then("I see the course {string}") do |name|
  expect(page).to have_content(name)
end

Then("I am on the course page for {string}") do |name|
  expect(page).to have_current_path(course_path(@courses.fetch(name)))
  expect(page).to have_content(name)
end

Then("I see episodes in order {string}") do |csv|
  names = csv.split(",").map(&:strip)
  positions = names.map { |n| page.text.index(n) }
  expect(positions).to eq(positions.compact.sort)
  expect(positions).not_to include(nil)
end

Then("I see the transcript {string}") do |text|
  expect(page).to have_content(text)
end

Then("I see a video player") do
  expect(page).to have_css("video", visible: :all)
end

# --- Quiz answering ---
When("I answer the quiz with {string}") do |answer|
  fill_in "answer", with: answer
  click_button I18n.t("quiz.submit")
end

Then("my answer {string} is stored for that quiz") do |answer|
  question = @episodes.values.map { |e| e.quiz_questions.first }.compact.last
  stored = QuizAnswer.find_by(user: @current_user, quiz_question: question)
  expect(stored).not_to be_nil
  expect(stored.answer).to eq(answer)
end
