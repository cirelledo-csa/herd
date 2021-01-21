# [aws-vault](https://github.com/99designs/aws-vault)

## MFA considerations

Generally we encourage the enforcement of mfa for human access to aws. This can
create some issues for programmatic access

## Install
to install on linux 

```
brew install aws-vault
```

to install on mac os x 

```
brew cask install aws-vault
```

set your iam profile

```
aws-vault add $youriamuser
```

modify your ~/.aws/config so that it has local mfa iam user profile and assumed role in 
profiles

```
[profile $youriamuser]
region=us-west-2
output=json
mfa_serial = arn:aws:iam::0123456789012:mfa/$youriamuser

[profile This]
source_profile = $youriamuser
parent_profile = $youriamuser
role_arn = arn:aws:iam::1234567890120:role/awsauth/ThisRole
mfa_serial = arn:aws:iam::0123456789012:mfa/$youriamuser

[profile That]
source_profile = $youriamuser
parent_profile = $youriamuser
role_arn = arn:aws:iam::2345678901201:role/awsauth/ThatRole
mfa_serial = arn:aws:iam::012345678901:mfa/$youriamuser

```

Here's how to execute commands on diff profiles:

```
aws-vault exec This -- aws s3 ls
aws-vault exec That -- aws s3 ls
```

Here's how to bring up a browser using a profile:

```
aws-vault login This
```


### parallelism

to install on mac os x 

```
brew cask install parallel
```

here's an example of how to execute a cli command and store the results locally
for any account profile that begin with acme:

```
mkdir /tmp/parallel && time for i in `av ls |grep ^acme | awk '{print $1}'`; do echo aws-vault  exec $i --   aws sts get-caller-identity ; done | parallel -j0 --result /tmp/parallel
```

## ZSH

### [ohmyzsh](https://ohmyz.sh/)

#### install

```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### plugins

zsh-aws-vault plugin has some helpful functions:


| Alias | Expression                                 |
|-------|--------------------------------------------|
| av    | aws-vault                                  |
| ave   | aws-vault exec                             |
| avl   | aws-vault login                            |
| avll  | aws-vault login -s                         |
| avli  | aws-vault login in private browsing window |
| avs   | aws-vault server                           |
| avsh  | aws-vault exec $1 -- zsh                   |
| avp   | list aws config / role ARNs                |

you can install aws-vault [plugin](https://github.com/blimmer/zsh-aws-vault)

```
cd ~/.oh-my-zsh/custom/plugins (you may have to create the folder)
git clone https://github.com/blimmer/zsh-aws-vault.git
```

you can add plugins to ~/.zshrc plugin section, eg:

```
plugins=(
git
zsh-aws-vault
)
```

You'll need to source ~/.zshrc to see changes take effect:

 ```
 source ~/.zshrc
 ```


#### themes

There are many diff themes you view
[here](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)

You can set theme by adding to ~/.zshrc

```
ZSH_THEME="agnoster-cust"
```

You can clone your own theme and customize to your liking:

```
cp -a  ~/.oh-my-zsh/themes/agnoster.zsh-theme   ~/.oh-my-zsh/themes/agnoster-cust.zsh-theme
```

```
prompt_aws_vault() {
local vault_segment
vault_segment="`prompt_aws_vault_segment`"
[[ $vault_segment != '' ]] && prompt_segment black red "$vault_segment"
}

build_prompt() {
RETVAL=$?
prompt_status
prompt_virtualenv
prompt_aws_vault
prompt_dir
prompt_git
prompt_end
}
```
