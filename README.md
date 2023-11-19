# Disclaimer

В соответствии с новыми законами Российской Федерации, я должен предупредить вас, что **не рекомендую** использовать полученную вами информацию для посещения web сайтов заблокированных на территории Российской Федерации!
Вся предоставленная информация должна быть использована исключительно в целях **обучения**.


In accordance with the new laws of the Russian Federation, I must warn you that **I do not recommend** using the information you have received to visit websites blocked in the territory of the Russian Federation!
All information provided should be used exclusively for **training purposes**.

# Xray-shadowsocks-vless
easy "one-click" install of xray server in Docker container

# How to
* execute `./deploy.sh`
* enjoy

# Main deploy.sh options
`./deploy.sh` script could be executed with special options
* `reload` - to "clear" init of xray container
* `remove` - to remove xray container and image
* `restart` - to recreate container (all settings will be saved)
* `uuid` - get random uuid (only if xray container is up)
* `your@email.com` - to provide your email for xray configuration file

to use option just add it after `./deploy.sh` command for example `./deploy.sh reload` or `./deploy.sh user@domain.com`

if `./deploy.sh` executed first time - it will build image, start xray container and print client config creds

if execute `./deploy.sh` without option again - it will just print client config creds

**WARN** if you provide an email as option it always reloads xray server and thats why client config creds. will be changed

# Xray base configuration
* shadowsocks port `23`
* shadowsocks method `2022-blake3-aes-128-gcm`
* shadowsocks transport `tcp` and `udp`

* vless port `443`
* vless transport `tcp`
* vless security `reality`

**WARN** server trys to simulate regular website it uses one address from `fake_sites.txt` randomly on startup

# Terraform config for DigitalOcean provider

to use IaC configuration add `digitalocean.tfvars` file to `terraform` folder of this project with folowing variables
* `do_token = "access_token_from_degitalocean_management_console"`
* `region = "ams3"`
* `size = "s-1vcpu-512mb-10gb"`
* `image = "debian-12-x64"`
* `hostname = "xray-server"`
* `email = "your@email.com"`
* `repo_url = "https://github.com/andrewfromtver/xray-shadowsocks-vless"` 

after it done init terraform provider and lanch cloud deployment from `terraform` folder of this project
* `terraform init`
* `terraform apply -var-file="digitalocean.tfvars"`

**WARN** Terraform configuration tested only on `Debian 12` image for DigitalOcean droplets
