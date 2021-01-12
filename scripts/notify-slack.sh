#!/bin/bash

# INCOMING_WEBHOOK_URL=https://hooks.slack.com/services/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 AUTHOR_NAME=AUTHOR_NAME SHA7=SHA7 BRANCH_NAME=BRANCH_NAME COMMIT_MSG=COMMIT_MSG PULL_REQUEST_ID=PULL_REQUEST_ID PREVIEW_URL=https://www.okta.com ./scripts/notify-slack.sh

variable_name=$(npx lerna list)

PREVIEW_URLS=""

for value in $variable_name; do
  PREVIEW_URLS+=" ∙ <https://$SHA7-$value|View $value>"
done

curl \
  -X POST \
  -H "Content-Type: application/json" \
  --data '
  {
    "blocks": [
      {
        "type": "context",
        "elements": [
          {
            "type": "mrkdwn",
            "text": ":rocket: *Preview Deployed*"
          },
          {
            "type": "mrkdwn",
            "text": "'"$AUTHOR_NAME"'@'"$SHA7"'"
          },
          {
            "type": "mrkdwn",
            "text": "'"$BRANCH_NAME"'"
          }
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "> '"$COMMIT_MSG"'"
        }
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "<https://github.com/okta/odyssey/pull/'"$PULL_REQUEST_ID"'|PR #'"$PULL_REQUEST_ID"'>*'"$PREVIEW_URLS"'*"
        }
      },
      {
        "type": "divider"
      }
    ]
  }
  ' \
  $INCOMING_WEBHOOK_URL
