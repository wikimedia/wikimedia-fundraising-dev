RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"
LIGHT_BLUE="\033[94m"

printf "${CYAN}**** Application URLs ****${RESET}\n"
printf "\n"
printf "${GREEN}CiviCRM WMFF URL:${RESET} https://wmff.localhost:$CIVICRM_PORT/civicrm\n"
printf "${GREEN}Civicrm WMFF user/password:${RESET} admin/admin\n"
printf "\n"
printf "${YELLOW}CiviCRM Core URL:${RESET} https://dmaster.localhost:$CIVICRM_PORT/civicrm\n"
printf "${YELLOW}Civicrm Core user/password:${RESET} admin/admin\n"
printf "\n"
printf "${BLUE}CiviCRM Standalone URL:${RESET} https://standalone-clean.localhost:$CIVICRM_PORT/civicrm\n"
printf "${BLUE}Civicrm Standalone user/password:${RESET} admin/admin\n"
printf "\n"
printf "${LIGHT_BLUE}Payments HTTPS URL:${RESET} https://localhost:$PAYMENTS_PORT\n"
printf "${LIGHT_BLUE}Payments HTTP URL:${RESET} http://localhost:$PAYMENTS_HTTP_PORT\n"
printf "${LIGHT_BLUE}Payments Test URL:${RESET} https://paymentstest$PROXY_FORWARD_ID.wmcloud.org (see README.md)\n"
printf "\n"
printf "${MAGENTA}Donate/Donut Wiki URL:${RESET} https://localhost:$DONUT_PORT/w/index.php/Special:FundraiserLandingPage?uselang=en&country=US\n"
printf "${MAGENTA}Donate/Donut Wiki HTTP URL:${RESET} http://localhost:$DONUT_HTTP_PORT/w/index.php/Special:FundraiserLandingPage?uselang=en&country=US\n"
printf "${MAGENTA}Donate/Donut Wiki Central Notice URL:${RESET} http://localhost:$DONUT_HTTP_PORT/w/index.php?title=Special:UserLogin&returnto=Special:CentralNotice\n"
printf "\n"
printf "${RED}E-mail Preference Center URL:${RESET} https://localhost:$EMAIL_PREF_CTR_PORT/index.php/Special:EmailPreferences\n"
printf "${BLUE}SmashPig IPN listener Test URL:${RESET} https://paymentsipntest$PROXY_FORWARD_ID.wmcloud.org (see README.md)\n"
printf "\n"
printf "${CYAN}Gr4vy Embed Form Proof-of-concept:${RESET} http://localhost:$GR4VY_PORT/embedded-checkout.php\n"
printf "${CYAN}GR4VY Sandbox console URL:${RESET} https://sandbox.wikimedia.gr4vy.app/\n"
printf "\n"
printf "${YELLOW}**** Fundraising Tools ****${RESET}\n"
printf "\n"
printf "Tools has a handful of useful scripts\n"
printf "${CYAN}Silverpop Update script:${RESET} ./scripts/silverpop-update.sh\n"
printf "${CYAN}Silverpop Export script:${RESET} ./scripts/silverpop-export.sh\n"
printf "${CYAN}Tox script:${RESET} ./scripts/tools-tox.sh (Python build & test tool)\n"
