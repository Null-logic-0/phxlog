alias Phxlog.Repo
alias Phxlog.Blogs.Blog

titles = [
  "Getting Started with Phoenix LiveView",
  "Why Elixir is Built for Concurrency",
  "Understanding the BEAM VM",
  "Phoenix vs Rails Performance",
  "Building JSON APIs with Phoenix",
  "Ecto Changesets Explained",
  "Real-Time Apps with Phoenix Channels",
  "Deploying Phoenix with Docker",
  "Authentication Strategies in Phoenix",
  "Background Jobs with Oban",
  "Testing Phoenix Apps",
  "Using Phoenix LiveDashboard",
  "File Uploads with LiveView",
  "Concurrency Patterns in Elixir",
  "Building a Blog in Phoenix",
  "Error Handling in Elixir",
  "Phoenix Contexts Best Practices",
  "Styling Phoenix with Tailwind",
  "Scaling Phoenix with Clustering",
  "Intro to OTP"
]

images = [
  "https://images.unsplash.com/photo-1518779578993-ec3579fee39f",
  "https://images.unsplash.com/photo-1517430816045-df4b7de11d1d",
  "https://images.unsplash.com/photo-1498050108023-c5249f4df085",
  "https://images.unsplash.com/photo-1504639725590-34d0984388bd",
  "https://images.unsplash.com/photo-1519389950473-47ba0277781c",
  "https://images.unsplash.com/photo-1484417894907-623942c8ee29",
  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d",
  "https://images.unsplash.com/photo-1492724441997-5dc865305da7",
  "https://images.unsplash.com/photo-1487058792275-0ad4aaf24ca7",
  "https://images.unsplash.com/photo-1461749280684-dccba630e2f6",
  "https://images.unsplash.com/photo-1518779578993-ec3579fee39f",
  "https://images.unsplash.com/photo-1517430816045-df4b7de11d1d",
  "https://images.unsplash.com/photo-1498050108023-c5249f4df085",
  "https://images.unsplash.com/photo-1504639725590-34d0984388bd",
  "https://images.unsplash.com/photo-1519389950473-47ba0277781c",
  "https://images.unsplash.com/photo-1484417894907-623942c8ee29",
  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d",
  "https://images.unsplash.com/photo-1492724441997-5dc865305da7",
  "https://images.unsplash.com/photo-1487058792275-0ad4aaf24ca7",
  "https://images.unsplash.com/photo-1461749280684-dccba630e2f6"
]

Enum.with_index(titles)
|> Enum.each(fn {title, i} ->
  %Blog{}
  |> Blog.changeset(%{
    title: title,
    content: "#{title} — Practical guide to Phoenix & Elixir.",
    image_path: Enum.at(images, i) <> "?auto=format&fit=crop&w=800&q=80"
  })
  |> Repo.insert!()
end)
