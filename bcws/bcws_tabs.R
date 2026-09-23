library(dplyr)

prefix_hq_kam_pwcc <- c(
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\Asset Mgmt Fire Centres",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\Chainsaw Administration",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\Communications Working Group",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\CWS",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\CWS Database",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\Fire Equipment Committee",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\Predictive Services",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\Prescribed Fire",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\PWCC Aviation Management",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\PWCC Operations",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\Structure Protection Program",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Project\\WRMP",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Publish\\Corporate Wildfire Services",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Publish\\Fire Investigation",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Publish\\PWCC",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Publish\\Systems",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Accounts Payable",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Air Tanker",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\All Hazards",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Aviation",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Corporate Wildfire Serv",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Fire Investigation",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Fire Investigation HR",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Fire Operations",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Legislation and Policy - FNIR",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Management",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Media Communications",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\PWCC_Contracts",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Structure Protection",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Training",
"\\\\sfp.idir.bcgov\\S165\\S65002\\!Workgrp\\Wildfire Risk"
)

prefix_hq_kam_pwcc <- tolower(prefix_hq_kam_pwcc)

prefix_depot <- c(
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Project\\CFED",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Publish\\CFED",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Administration",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\BCWS FORMS",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\DCO",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Equipment",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\FINADMIN_ScanDocs",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Finance",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Fleet",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\HR",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\IMIS",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Kit Lists",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Maintenance & Retrieval",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Mobile Camps",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Pictures",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Purchasing",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Security",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\SOG-SOP",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Specificiations",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Warehousing",
  "\\\\sfp.idir.bcgov\\s165\\s65010\\!Workgrp\\Work Schedules and Standby Lists"
)

prefix_depot <- tolower(prefix_depot)

prefix_training <- c(
  "\\\\bcwsdata.nrs.bcgov\\training$\\Aviation",
  "\\\\bcwsdata.nrs.bcgov\\training$\\Chainsaw",
  "\\\\bcwsdata.nrs.bcgov\\training$\\Danger Tree",
  "\\\\bcwsdata.nrs.bcgov\\training$\\Finance",
  "\\\\bcwsdata.nrs.bcgov\\training$\\Provincial",
  "\\\\bcwsdata.nrs.bcgov\\training$\\PWCC G Drive files",
  "\\\\bcwsdata.nrs.bcgov\\training$\\Recruiting",
  "\\\\bcwsdata.nrs.bcgov\\training$\\RX Fire Planning",
  "\\\\bcwsdata.nrs.bcgov\\training$\\Safety",
  "\\\\bcwsdata.nrs.bcgov\\training$\\TEAMS",
  "\\\\bcwsdata.nrs.bcgov\\training$\\Training Plans",
  "\\\\bcwsdata.nrs.bcgov\\training$\\WSBC"
)

prefix_training <- tolower(prefix_training)

prefix_hq_victoria <- c(
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Asset Mgmt",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Assets",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Media",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Publish\\Common Files\\1800 TEAMS and RRT",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\PWRC -1-800 Centre",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\PWRC Supervisor",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\PWRC Team Lead",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Director, Corporate Governance",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Project\\Corporate Wildfire Services",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\AdminMgrs",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\CorpServ",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Cost Recovery",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\CS_Managers",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\CWS HQ",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\CWS Leadership Team",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\DEC Project",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Finance",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Financial Reviews",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Procurement",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\ELT",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Executive Support",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Project\\FN Cultural Sites",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Training",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Project\\Recruitment",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Fire Weather Program",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\R and I 2018",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\SAC",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Strategic Initiatives",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Wildfire Land Based Recovery",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Project\\Prevention Promotional Material",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Publish\\Common Files\\FireScience",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Publish\\Common Files\\Presentation\\Fire Management Planning",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Cultural and Prescribed Fire",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Fire Management",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Fire Sciences",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Prevention",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Prevention_Mgmt",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Project\\Policy",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Project\\Wildfire Claims",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\BCWS Legal",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\OTBH Determinations",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Wildfire Risk Information Governance",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Publish\\Common Files\\Communications and Engagement - Prevention",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Publish\\Common Files\\Presentation",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Publish\\Common Files\\Wildfire Prevention Community of Practice",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Publish\\Common Files\\WxData",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Communications and Engagement _Prevention",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Corporate Priorites and Communications",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\HQ Fatigue Tracker",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\International",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Jutland",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Strategic Engagement",
  "\\\\sfp.idir.bcgov\\s165\\s65011\\!Workgrp\\Wildfire Managers"
)

prefix_hq_victoria <- tolower(prefix_hq_victoria)

get_prefixes <- function() {
  list(
    hq_kam_pwcc = prefix_hq_kam_pwcc,
    depot = prefix_depot,
    hq_victoria = prefix_hq_victoria
  )
}
