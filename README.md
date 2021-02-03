# s3-migration-glacier-standard
Migrate S3 Glacier Objects to Standard Class

### Reference:
* https://www.linuxschoolonline.com/how-i-could-restore-1-million-files-from-glacier-to-standard-s3/

### In Short

1. list.py : Python script which uses booto3 package to get all the objects of an s3 bucket
```
 ./list.py > objects.txt
```
2. grep command to extract all the lines that contain Glacier
```
   grep GLACIER objects.txt > glacier.txt
```
3. clean.pl: Perl script to extract the object names from glacier.txt
```
   clean.pl > just_objects.txt
```
4. If there are any leading and trailing quotes, then just remove them using VIM formatting

5. If the list of objects is very huge then we can split the file into parts of 100000. This will split the file into objects of 100000 each with names xab, xab, xac....
```
split -100000 just_objects.txt
```
6. Use s3cmd tool to restore the objects from Glacier to Standard. Run the while command for each file which we splitted. On UI you will still see the Object class as GLACIER. Don't get confused. One more step is remaining to change the class to STANDARD.
```
while read line; do
    s3cmd restore --restore-days=7 --restore-priority=bulk "s3://bucket-name/${line}"
done < xaa
```
7. Check the status of restore using below s3api command. Replace the bucket name with yours and key name will be any objects name for which you want to check the status.
```
aws s3api head-object --bucket my-bucket --key index.html
```
While the archive is being retrieved, the JSON will contain a Restore key similar to:
```
"Restore": "ongoing-request=\"true\""
```
When the archive is ready to be downloaded, the Restore key will change to something like:
```
"Restore": "ongoing-request=\"false\", expiry-date=\"Thu, 17 Sep 2020 00:00:00 GMT\""
```
8. Finally using aws s3 cp command change the object classes to STANDARD. If you see the Object class now on objects, it will be showing as STANDARD.
```
while read line; do
    aws s3 cp --recursive "s3://bucket-name/${line}" "s3://bucket-name/${line}"  --storage-class=STANDARD --force-glacier-transfer
done < xaa
```
9. Copy them to another s3 bucket. Say from old env to new env.
Add S3 bucket policy in old env, which grants access to aws user(who already have access to bucket in new env) who wants to access the bucket in old env. Refer to s3-policy.json.
Then run below command to initate the copy.
```
while read line; do
    aws s3 cp --recursive "s3://bucket-name/${line}" "s3://new-bucket-name/${line}"  --profile <aws-profile>
done < xaa
```
10. The restored objects will remain in STANDARD class for the number of --restore-days mentioned in s3cmd restore command. After that they will be moved back to GLACIER.
