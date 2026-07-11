# --- Local LLM client (S32) ---
# Spins up an in-process TCP server that speaks the Ollama /api/chat shape, so we
# can assert routing + reply without any external dependency or real model.
require "socket"
require "json"

Given("a fake local LLM that replies {string}") do |reply|
  @llm_hits = 0
  @llm_socket = TCPServer.new("127.0.0.1", 0)
  @llm_port = @llm_socket.addr[1]
  @llm_thread = Thread.new do
    loop do
      client = begin
        @llm_socket.accept
      rescue StandardError
        break
      end
      begin
        client.gets # request line
        headers = {}
        while (line = client.gets) && line != "\r\n"
          k, v = line.split(":", 2)
          headers[k.strip.downcase] = v.to_s.strip if v
        end
        len = headers["content-length"].to_i
        client.read(len) if len > 0
        @llm_hits += 1
        body = { message: { role: "assistant", content: reply } }.to_json
        client.write("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n" \
                     "Content-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}")
      ensure
        client.close rescue nil
      end
    end
  end
end

After do
  @llm_socket&.close rescue nil
  @llm_thread&.kill
  ENV.delete("LOCAL_LLM_URL")
  ENV.delete("LOCAL_LLM_MODEL")
  ENV.delete("LOCAL_LLM_API")
end

Given("the local LLM endpoint is configured to that server") do
  ENV["LOCAL_LLM_URL"] = "http://127.0.0.1:#{@llm_port}"
  ENV["LOCAL_LLM_MODEL"] = "test-model"
end

Given("the local LLM is not configured") do
  ENV.delete("LOCAL_LLM_URL")
end

When("the assistant answers a question about an episode") do
  course = Course.create!(name: "C", details: "d", published: true)
  episode = course.episodes.create!(name: "E", title: "E", kind: :movie, transcript: "hello world")
  @assistant_reply = Ai::Assistant.new(episode).answer("what is this about?")
end

Then("the request was sent to the local endpoint") do
  expect(@llm_hits).to be >= 1
end

Then("the reply is {string}") do |text|
  expect(@assistant_reply).to eq(text)
end

Then("a non-empty reply is returned") do
  expect(@assistant_reply.to_s.strip).not_to be_empty
end
