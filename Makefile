# デフォルトの環境をstg ########################################################
ENV ?= stg

# terraform実行用 ##############################################################

# "make init"で実行
# "make init ENV=prod"とすると、envs/prod ディレクトリで terraform initを実行
init:
	terraform -chdir=envs/$(ENV) init

# "make plan"で実行
# "make plan ENV=prod"とすると、envs/prod ディレクトリで、prod.tfvarsを読み込んだ上、terraform planを実行
plan:
	terraform -chdir=envs/$(ENV) plan

# "make apply" で実行
# "make apply ENV=prod"とすると、envs/prod ディレクトリで、prod.tfvarsを読み込んだ上、terraform applyを実行
apply:
	terraform -chdir=envs/$(ENV) apply

# "make destroy" で実行
# "make destroy ENV=prod"とすると、envs/prod ディレクトリで、prod.tfvarsを読み込んだ上、terraform destoryを実行
destroy:
	terraform -chdir=envs/$(ENV) destroy

# "make console"で実行
# "make console ENV=prod"とすると、envs/prod ディレクトリで terraform consoleを実行
console:
	terraform -chdir=envs/$(ENV) console


# tftui実行用 ##################################################################

# "make tftui" で実行
# "make tftui ENV=prodとすると、envs/prod ディレクトリで tftuiを実行"
tftui:
	cd envs/$(ENV) && tftui
