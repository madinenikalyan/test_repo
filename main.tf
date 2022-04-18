terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"
      org_service_url = ""
      personal_access_token = "xyqjdngx4yiyowxqp6pezzoc2pj67modzyxttzcz2e7pzigzguip"
    }
  }
}
 
resource "azuredevops_project" "project" {
  name               = "TestProject"
  visibility         = "private"
  version_control    = "Git"
}

resource "azuredevops_git_repository" "gitrepo" {
  project_id = azuredevops_project.project.id
  name       = "Sample Import an Existing Repository"
  initialization {
    init_type   = "Import"
    source_type = "Git"
    source_url  = ""
  }
}

resource "azuredevops_git_repository" "repo" {
  project_id = azuredevops_project.project.id
  name       = "Existing Git Repository"
  default_branch = "refs/heads/main"
  initialization {
    init_type = "Clean"
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to initialization to support importing existing repositories
      # Given that a repo now exists, either imported into terraform state or created by terraform,
      # we don't care for the configuration of initialization against the existing resource
      initialization,
    ]
  }
}
 
resource "azuredevops_build_definition" "build" {
  project_id = azuredevops_project.test.id
  name       = "Sample Pipeline"
 
  repository {
    repo_type   = "TfsGit"
    repo_name   = azuredevops_git_repository.repo.name
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = "azure-pipelines/deploy.yml"
  }
}