#!/bin/bash

LERNA_LIST=$(npx lerna list)
PREVIEW_URLS=""
for value in $LERNA_LIST; do
  PREVIEW_URLS+="$SHA7$value"
done

echo "${PREVIEW_URLS}" 

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
          "text": "<https://github.com/okta/odyssey/pull/'"$PULL_REQUEST_ID"'|PR #'"$PULL_REQUEST_ID"'> ∙ *<'"$PREVIEW_URL"'|View Preview>*"
        }
      },
      {
        "type": "divider"
      }
    ]
  }
  ' \
  $INCOMING_WEBHOOK_URL
