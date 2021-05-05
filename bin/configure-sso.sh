#!/bin/bash
echo "setting up aws cli access with sso"
echo "note you will need v2 of aws cli"
aws --version
echo "here are some helpful hints about the best answers:"
echo
echo "SSO start URL [None]: https://yourssoprefix.awsapps.com/start#/"
echo "SSO Region [None]: us-west-2"
echo "choose any account and role (stable account and ro role are best)"
echo "CLI default client Region [us-west-2]:"
echo "CLI default output format [None]: json"
echo "CLI profile name [your-role-123456789012]: short-and-memorable-profile-name"
echo
aws configure sso
echo
echo "you should now be able to login via sso with:"
echo
echo "'aws sso login --profile short-and-memorable-profile-name'"
