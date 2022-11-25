
# CODEPIPELINE
resource "aws_codepipeline" "svc2-pipeline" {
  name     = "svc2-pipeline"
  role_arn = "${data.aws_iam_role.pipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.bucket-artifact.bucket}"
    type     = "S3"
  }
  # SOURCE
  stage {
    name = "Source"
    action {
      name = "Source"
      category = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = "1"
      output_artifacts = ["source_output"]

      configuration = {
        OAuthToken = var.github_token
        Owner = var.github_owner
        Repo = var.github_repo
        Branch = var.github_branch
      }
    }
  }
  # BUILD
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = "${var.build_project}"
      }
    }
  }
  # DEPLOY
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = var.cluster_name
        ServiceName = var.service2
        FileName    = "service2.json"
      }
    }
  }
}