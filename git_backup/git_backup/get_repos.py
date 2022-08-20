import os
from github import Github

username = os.environ["GIT_USERNAME"]
password = os.environ["GIT_PASSWORD"]
g = Github(username, password)

user = g.get_user()
for repo in user.get_repos():
    print(f"github.com/{repo.full_name}")

