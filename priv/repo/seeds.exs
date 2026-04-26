alias Phxlog.Repo
alias Phxlog.Blogs.Blog
alias Phxlog.Blogs.Like
alias Phxlog.Accounts.User
alias Phxlog.Blogs.Comment

import Ecto.Changeset

now = DateTime.utc_now() |> DateTime.truncate(:second)

#  Admin user
%User{}
|> change(%{
  full_name: "Admin",
  email: "admin@example.com",
  is_admin: true,
  confirmed_at: now
})
|> Repo.insert!(on_conflict: :nothing, conflict_target: :email)

# 20 Users
Enum.each(1..20, fn i ->
  %User{}
  |> change(%{
    full_name: "User #{i}",
    email: "user#{i}@example.com",
    is_admin: false,
    confirmed_at: now
  })
  |> Repo.insert!(on_conflict: :nothing, conflict_target: :email)
end)

# Reload users (important!)
users = Repo.all(User)

#  Blog data
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

# Insert Blogs
blogs =
  Enum.with_index(titles)
  |> Enum.map(fn {title, i} ->
    user = Enum.random(users)

    %Blog{}
    |> Blog.changeset(%{
      title: title,
      content: "#{title} — Practical guide to Phoenix & Elixir.",
      image_path: Enum.at(images, i) <> "?auto=format&fit=crop&w=800&q=80",
      user_id: user.id
    })
    |> Repo.insert!()
  end)

# 💬 Comment content pool
comments_content = [
  "Great post!",
  "Very helpful 🔥",
  "Loved this explanation",
  "Super clear, thanks!",
  "This saved me hours",
  "Nice work 👏",
  "Can you go deeper on this?",
  "Exactly what I needed",
  "Clean and simple explanation",
  "Elixir ❤️",
  "Phoenix is amazing",
  "This is gold",
  "Bookmarking this",
  "Helped me a lot",
  "Well written!",
  "Awesome guide",
  "Thanks for sharing",
  "Really insightful",
  "Clear and practical",
  "Perfect timing for me"
]

#  Insert Comments (20 per blog)
Enum.each(blogs, fn blog ->
  Enum.each(1..20, fn _ ->
    user = Enum.random(users)

    %Comment{}
    |> change(%{
      content: Enum.random(comments_content),
      blog_id: blog.id,
      user_id: user.id
    })
    |> Repo.insert!()
  end)
end)

# Insert Likes (up to 20 unique likes per blog)

Enum.each(blogs, fn blog ->
  users
  |> Enum.shuffle()
  |> Enum.take(20)
  |> Enum.each(fn user ->
    %Like{}
    |> Ecto.Changeset.change(%{
      blog_id: blog.id,
      user_id: user.id
    })
    |> Repo.insert!(on_conflict: :nothing, conflict_target: [:blog_id, :user_id])
  end)
end)

IO.puts("✅ Likes inserted successfully!")

IO.puts("✅ Seeds inserted successfully!")
