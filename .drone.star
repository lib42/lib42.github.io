def main(ctx):
  data = dict(incubating=["nold360/heqet", "lib42/charts"],
              stable=["nold360/docker-borgserver"])
  
  cmd=[]
  cmd.append('git remote add gh-token "https://$${GH_TOKEN}@github.com/lib42/lib42.github.io"')
  cmd.append('git fetch gh-token && git checkout gh-token/docs')
  for state in data:
    for project in data[state]:
      name=project.split('/')[1]
      cmd.append("wget -O docs/projects/%s/%s.md -nv https://raw.githubusercontent.com/%s/master/README.md" % (state, name, project))
      cmd.append("echo -e '\n## Project URL\n\n[Github / %s](https://github.com/%s)' >> docs/projects/%s/%s.md" % (project, project, state, name))
  cmd.append('cp README.md docs/index.md')
  cmd.append('mkdocs gh-deploy --remote-name gh-token --remote-branch main')

  return {
    "kind": "pipeline",
    "type": "kubernetes",
    "name": "build-page",
    "steps": [
      {
        "name": "build",
        "image": "squidfunk/mkdocs-material",
        "commands": cmd,
        "environment": {
          "GH_TOKEN": {
            "from_secret": "gh_token"
          }
        }
      }
    ]
  }
