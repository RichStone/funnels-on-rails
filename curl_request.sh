#!/bin/bash

# This curl command replicates the ClickFunnels API request to list contacts with a specific email address
curl -X GET \
  "https://funnelsonrails.myclickfunnels.com/api/v2/workspaces/365069/contacts?filter%5Bemail_address%5D=hey%40richsteinmetz.com" \
  -H "Authorization: Bearer APIKEY" \
  -H "Accept: application/json"