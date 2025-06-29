#!/bin/bash

today=$(date "+%Y-%m-%d" )
twoDaysBack=$(date "+%Y-%m-%d" --date="2 day ago")
cloud_type=$1
BASEDIR=$(dirname "$0")

display_help() {
	echo "Usage: $0 [option...] " >&2
	echo "#Arguments
	#cloud_type => 1, eg: AZURE/GCP"
    exit 1
}

if [ "$#" -lt 1 ] ;then
  display_help
  exit ;
fi

cnvtCloudTypeToUppr=${cloud_type^^}
echo "Cloud Type is -> $cnvtCloudTypeToUppr"
printf "\n"

fetchJson(){

        echo "Snapshot Execution Date and Time -> $today"

        #readSanpshotDisk=$(jq ."$cnvtCloudTypeToUppr"[] $BASEDIR/json/snapshot.json)
        #printf 'Following Disk snapshot will be taking -> \n%s\n' "${readSanpshotDisk[@]}"
        #printf "\n"

        countArrayReturn=$(jq '.'$cnvtCloudTypeToUppr'|length' $BASEDIR/json/snapshot.json)
        echo "Count of snapshot to take -> $countArrayReturn"
        printf "\n"

}


azureSnapshotCreate(){
    
    for((i=0;i<$countArrayReturn;i++))
    do
        snapshot_json=$(jq -r ."$cnvtCloudTypeToUppr"[$i] $BASEDIR/json/snapshot.json)
        diskName=$(echo $snapshot_json | jq -r '.diskName')
        snapshotName=$(echo $snapshot_json | jq -r '.snapshotName')
        resourceGroupSnapshot=$(echo $snapshot_json | jq -r '.resourceGroupSnapshot')
        snapshotType=$(echo $snapshot_json | jq -r '.snapshotType')
        resource_id_disk=$(echo $snapshot_json | jq -r '.resource_id_disk')
        tags=$(echo $snapshot_json | jq -r '.tags')
        snapshotStorageType=$(echo $snapshot_json | jq -r '.snapshotStorageType')

        printf "\n"
        printf "Creating snapshot for -> diskName -: %s || snapshotName -: %s || resourceGroupSnapshot -: %s || snapshotType -: %s || snapshotStorageType -: %s || resource_id_disk -: %s || tags -: %s\n" "$diskName" "$snapshotName-$today" "$resourceGroupSnapshot" "$snapshotType" "$snapshotStorageType" "$resource_id_disk" "$tags"
        printf "\n"

        createSnapshot=$(az snapshot create \
        --resource-group $resourceGroupSnapshot \
        --source $resource_id_disk/$diskName \
        --sku $snapshotStorageType \
        --incremental $snapshotType \
        --name $snapshotName-$today \
        --tags $tags);
        
        printf "created snapshot for $diskName -> %s\n" "$createSnapshot"

    done

}

azureSnapshotDelete(){

    for((i=0;i<$countArrayReturn;i++))
    do
        snapshot_json=$(jq -r ."$cnvtCloudTypeToUppr"[$i] $BASEDIR/json/snapshot.json)
        snapshotName=$(echo $snapshot_json | jq -r '.snapshotName')
        resourceGroupSnapshot=$(echo $snapshot_json | jq -r '.resourceGroupSnapshot')
        
        printf "\n"
        printf "delete snapshot for -> snapshotName -: %s || resourceGroupSnapshot -: %s\n" "$snapshotName-$twoDaysBack" "$resourceGroupSnapshot"
        printf "\n"        
        
        deleteSnapshot=$(az snapshot delete \
        --name $snapshotName-$twoDaysBack \
        --resource-group $resourceGroupSnapshot); 

    done

}

gcpSnapshotCreate(){

    for((i=0;i<$countArrayReturn;i++))
    do
        snapshot_json=$(jq -r ."$cnvtCloudTypeToUppr"[$i] $BASEDIR/json/snapshot.json)
        diskName=$(echo $snapshot_json | jq -r '.diskName')
        snapshotName=$(echo $snapshot_json | jq -r '.snapshotName')
        sourceDiskZone=$(echo $snapshot_json | jq -r '.sourceDiskZone')
        storageLocation=$(echo $snapshot_json | jq -r '.storageLocation')
        projectName=$(echo $snapshot_json | jq -r '.projectName')
        tags=$(echo $snapshot_json | jq -r '.tags')

        printf "\n"
        printf "Creating snapshot for -> diskName -: %s || snapshotName -: %s || sourceDiskZone -: %s || storageLocation -: %s || projectName -: %s || tags -: %s\n" "$diskName" "$snapshotName-$today" "$sourceDiskZone" "$storageLocation" "$projectName" "$tags"
        printf "\n"

        createSnapshot=$(gcloud compute snapshots create $snapshotName-$today \
        --project=$projectName \
        --source-disk=$diskName \
        --labels=$tags \
        --source-disk-zone=$sourceDiskZone \
        --storage-location=$storageLocation)
    done


}

gcpSnapshotDelete(){

    for((i=0;i<$countArrayReturn;i++))
    do
        snapshot_json=$(jq -r ."$cnvtCloudTypeToUppr"[$i] $BASEDIR/json/snapshot.json)
        snapshotName=$(echo $snapshot_json | jq -r '.snapshotName')
        
        printf "\n"
        printf "delete snapshot for -> snapshotName -: %s\n" "$snapshotName-$twoDaysBack"
        printf "\n"
    
        deleteSnapshot=$(gcloud compute snapshots delete $snapshotName-$twoDaysBack)
    done

}



case $cnvtCloudTypeToUppr in
    AZURE)
          fetchJson
          azureSnapshotCreate
          azureSnapshotDelete
          ;;
    GCP)   
          fetchJson    
          gcpSnapshotCreate
          gcpSnapshotDelete
          ;;
    *)
          echo "cloud type -> different"
          exit 1
          ;;   
esac
               
