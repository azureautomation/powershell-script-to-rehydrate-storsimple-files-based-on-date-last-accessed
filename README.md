Powershell script to rehydrate StorSimple files based on date last accessed
===========================================================================

            

In some rare situations, a StorSimple hybrid cloud storage device can reach a point where a large cold data dump has displaced hot data to the cloud (Azure). This happens if the device local SSD and SAS tiers are full (including reserved space that cannot
 be used for incoming data blocks from the iSCSI interfaces). In this situation, most READ requests will be followed by Azure WRITE requests. What's happening is that the device is retrieving the requested data from Azure, and to make room for it on the local
 tiers it's displacing the coldest blocks back to Azure. This may result in poor device performance especially in situations where the device bandwidth to/from the Internet is limited. 


In the scenario above, if the cold data dump occurred 8 days ago for example, we may be interested in re-hydrating files last access in the week prior to that point in time. This Powershell script does just that. It identifies files under a given directory
 based on date last accessed, and reads them. By doing so, the StorSimple device brings these files to the top SSD tier. This is meant to run off hours, and is tested to improve file access for users coming online the next day.


For more details see [https://superwidgets.wordpress.com/2016/03/17/powershell-script-to-re-hydrate-storsimple-files-based-on-date-last-accessed/](https://superwidgets.wordpress.com/2016/03/17/powershell-script-to-re-hydrate-storsimple-files-based-on-date-last-accessed/)




 




        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
