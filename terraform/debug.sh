#!/bin/bash

planfile="tfplan.out"
DEBUG_THE_DEBUG=false     # true / false
DRY_RUN=false              # true / false  Always leave "true" in production!!
DISABLE_FILE_WATCHER=true # true / false

# env > env_manual.sh
dattt=`date`
echo -e "\n\n\n\n #> ${dattt} | Starting... ##################### \n"

if $DISABLE_FILE_WATCHER &>/dev/null ; then
    if $VSCODE_PID  &>/dev/null; then
        true  # echo " #> Running manually"
    else
        echo " #> Running inside vscode extension (File Watcher) and DISABLE_FILE_WATCHER is set to true. Exiting..."
        exit 0
    fi
fi


function cleanup()
{
    echo " #> Cleaning up..."
    rm -f ${planfile}
    rm -f tfstdout_plan.out
    rm -f tfstderr_plan.out
}
trap cleanup EXIT SIGINT SIGTERM SIGQUIT SIGKILL

if ! $(aws sts get-caller-identity &> /dev/null ); then 
    echo " #> AWS SSO session expired. Refreshing..." ;
    aws sso login
    echo " #> Finished AWS SSO Refreshing!" ;
fi

# Build extra arguments for Terraform
if $VSCODE_PID  &>/dev/null; then
        true  # Running manually
    else
        #echo " #> Running inside vscode extension (File Watcher) "
        tf_extra_args="-auto-approve -no-color"
        
    fi

TF_LOG=debug terraform plan  ${tf_extra_args} -detailed-exitcode -var-file prod.tfvars -out ${planfile} > tfstdout_plan.out 2> tfstderr_plan.out
plan_ret=$?
# TF_LOG=debug terraform plan -lock=false -no-color -detailed-exitcode -var-file prod.tfvars -out ${planfile} > tfstdout_plan.out 2> tfstderr_plan.out

if $DEBUG_THE_DEBUG &>/dev/null; then
    echo " #> TF Plan return code: ${plan_ret}"
    cat tfstdout_plan.out
    cat tfstderr_plan.out
fi

if [ $plan_ret -eq 0 ]; then
    echo " #> No changes detected. Exiting..."
    exit 0
fi

if [ $plan_ret -eq 2 ]; then
    if $DRY_RUN &>/dev/null; then
        echo -e " #> Dry run mode enabled. ##################### \n"
        cat tfstdout_plan.out
        echo -e "\n #>   Exiting... \n"
        exit 0
    fi

    echo "  #> Changes detected. Applying..."
    cat tfstdout_plan.out
    echo -e  "\n #> Applying changes...    ################################### \n"
    terraform apply ${planfile}
    exit 0
fi


echo " #> Error creating plan file. Exiting..."
echo " #> Finished in error! (ERROR: ${plan_ret})"
cat tfstderr_plan.out
exit 0
