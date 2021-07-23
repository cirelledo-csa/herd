#!/bin/bash
echo "this script will attempt to create aws cli profiles from your sso profiles"
echo "you'll need acces to a working sso login credential"
echo "hint you can do this with 'aws sso login --profile youreasytorememberprofile'"
echo "here are the cache files aws uses for sso authentication"
ls -ltar ~/.aws/sso/cache/* |grep -v botocore
echo
echo "please enter the fully qualified most recent aws sso cache file(not the botocore-client-id-us-west-2.json"
read filename
token=$(cat "$filename" | jq -r .accessToken)
echo "The following output can be added to ~/.aws/config"
echo
echo "enter your sso portal name, eg the value of yourportal in https://yourportal.awsapps.com/start#/"
read portal
aws sso list-accounts --access-token $token | jq -r '.accountList[]'  | jq -r '[ .accountName, .accountId] | @csv'  | sed -e 's/"//g' | while read line
do
	account_name=$(echo $line | awk -F , '{print $1}' | sed -e 's/ /-/g');
	account_id=$(echo $line | awk -F , '{print $2}');
	for role in $(aws sso list-account-roles  --account-id $account_id --access-token $token  | jq -r '.roleList[].roleName'); do
		echo "[profile $portal-$account_name-$role]";
		echo output = json;
		echo region = us-west-2;
		echo sso_account_id = $account_id;
		echo sso_region = us-west-2;
		echo sso_role_name = $role;
		echo sso_start_url = "https://$portal.awsapps.com/start#/"
	done
done
