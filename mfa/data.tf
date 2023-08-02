data "aws_iam_policy_document" "mfa" {
  statement {
    sid = "AllowIndividualUserToManageTheirOwnMFA"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListVirtualMFADevices",
      "iam:DeactivateMFADevice",
      "iam:GetUser",
      "iam:ListMFADevices",
      "iam:UpdateUser",
    ]
    resources = [
      "arn:aws:iam::*:mfa/${aws_iam_user.user.name}",
    ]
  }

    statement {
        sid = "AllowIndividualUserToListOnlyTheirOwnMFA"
        effect = "Allow"
        actions = [
        "iam:ListMFADevices",
        ]
        resources = [
        "arn:aws:iam::*:mfa/${aws_iam_user.user.name}",
        ]
    }

    statement {
        sid = "AllowIndividualUserToDeactivateOnlyTheirOwnMFA"
        effect = "Allow"
        actions = [
        "iam:DeactivateMFADevice",
        ]
        resources = [
        "arn:aws:iam::*:mfa/${aws_iam_user.user.name}",
        ]
    }
}



