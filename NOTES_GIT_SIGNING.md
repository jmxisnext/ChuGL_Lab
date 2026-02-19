# Repo-local Git note

This repo disables commit signing locally to unblock bootstrap:

- commit.gpgsign = false

Reason: global Git config on this machine requires SSH signing, but user.signingkey was not configured at bootstrap time.
If/when you want signed commits here, configure SSH signing and remove the local override.
