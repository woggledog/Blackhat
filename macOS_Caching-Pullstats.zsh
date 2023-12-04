#!/bin/zsh
# requires BREW to be installed and the jq package: https://formulae.brew.sh/formula/jq
# requires also for the content caching service to be up, running and configured
# https://developer.apple.com/documentation/devicemanagement/contentcachinginformationresponse/statusresponse?changes=latest_minor
# this, every 900 seconds, takes the response from "AssetCacheManagerUtil status"
# takes each of the parameters that are needed
# and chucks them into a SQLite DB

# uncomment below to create your metrics database using SQLite3
# sqlite3 ~/Downloads/Metrics.db "create table cachedetails(idpk INTEGER PRIMARY KEY, Isactive STRING, ActualCacheUsed NUMBER, TypeiCloud NUMBER, TypeiOS NUMBER, TypeMac NUMBER, TypeOther NUMBER, CacheFree NUMBER, CacheUsed NUMBER, CacheLimit NUMBER, MaxCachePressureLast1Hour STRING, TotalBytesReturnedToClients NUMBER,  TotalBytesStoredFromOrigin NUMBER, recordedAt datetime);"


# never managed to get launch daemons working so we are stuck with an infinite loop. Apologies

while :
do
	Isactive=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.Active')
	ActualCacheUsed=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.ActualCacheUsed') 
	TypeiCloud=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.CacheDetails.iCloud')
	typeiOS=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.CacheDetails."iOS Software"')
	TypeMac=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.CacheDetails."Mac Software"')
	TypeOther=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.CacheDetails.Other')
	CacheFree=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.CacheFree') 
	CacheUsed=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.CacheUsed')  
	CacheLimit=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.CacheLimit') 
	MaxCachePressureLast1Hour=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.MaxCachePressureLast1Hour')
	TotalBytesReturnedToClients=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.TotalBytesReturnedToClients')
	TotalBytesStoredFromOrigin=$(AssetCacheManagerUtil status -j &>/dev/null | jq '.result.TotalBytesStoredFromOrigin')
	dateNow=$(date +"%D %T")


	sqlCommand="insert into cachedetails (Isactive, ActualCacheUsed, TypeiCloud, typeiOS, TypeMac, TypeOther, CacheFree, CacheUsed, CacheLimit, MaxCachePressureLast1Hour, TotalBytesReturnedToClients, TotalBytesStoredFromOrigin, recordedAt) \
values (\"$active\","$ActualCacheUsed",\"$TypeiCloud\",\"$TypeiOS\", \"$TypeMac\", \"$TypeOther\", \"$CacheFree\", \"$CacheUsed\", \"$CacheLimit\", \"$MaxCachePressureLast1Hour\", \"$TotalBytesReturnedToClients\", \"$TotalBytesStoredFromOrigin\", \"$dateNow\");"

	Echo $sqlCommand

	sqlite3 ~/Downloads/Metrics.db $sqlCommand

	Sleep 900

done
