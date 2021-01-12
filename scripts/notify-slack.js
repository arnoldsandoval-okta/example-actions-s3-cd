const https = require('https');
const { exec } = require('child_process');
const { 
  SLACK_WEBHOOK_URL, 
  AUTHOR_NAME,
  SHA7,
  BRANCH_NAME,
  COMMIT_MSG,
  PULL_REQUEST_ID,
} = process.env

const slackPayload = (changedPackages) => ({
  'username': 'Odyssey Preview',
  'icon_emoji': ':boat:',
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
          "text": `${AUTHOR_NAME}@${SHA7}`
        },
        {
          "type": "mrkdwn",
          "text": `${BRANCH_NAME}`
        }
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": `> ${COMMIT_MSG}`
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": [
          `<https://github.com/okta/odyssey/pull/${PULL_REQUEST_ID}|PR #${PULL_REQUEST_ID}>`,
          ...changedPackages.map(({name}) => `<https://${SHA7}.${name}.ods.so|View ${name}>`)
        ].join(" ∙ ")
      }
    },
    {
      "type": "divider"
    }
  ]
});

const sendMessage = (webhookURL = SLACK_WEBHOOK_URL, changedPackages) =>
  new Promise((resolve, reject) => {
    const packages = JSON.parse(changedPackages)
    const message = slackPayload(packages)
    const requestOptions = {
      method: 'POST',
      header: {
        'Content-Type': 'application/json'
      }
    }

    const req = https.request(webhookURL, requestOptions, (res) => {
      let response = ''


      res.on('data', (d) => {
        response += d
      })

      res.on('end', () => {
        resolve(response)
      })
    })

    req.on('error', (e) => {
      reject(e)
    })

    req.write(JSON.stringify(message))
    req.end()
  });


(async function () {
   exec('./node_modules/.bin/lerna list --since master --json', async (e, stdout) => {
    try {
      await sendMessage(SLACK_WEBHOOK_URL, stdout)
    } catch (e) {
      console.error(e)
    }
  })
})()