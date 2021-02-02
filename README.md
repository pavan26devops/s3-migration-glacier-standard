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
6. Use s3cmd tool to rstore the objects from Glacier to Standard. Run the while command for each file which we splitted. On UI you will still see the Object class as GLACIER. Dont get confused. One more step is remianing to change the class to STANDARD.
``` 
while read line; do
    s3cmd restore --restore-days=7 --restore-priority=bulk "s3://bucket-name/${line}"
done < xaa
``` 
7. Finally using aws s3 cp command change the object classes to STANDARD. If you see the Object class now on objects, it will be showing as STANDARD.
``` 
while read line; do
    aws s3 cp "s3://bucket-name/${line}" "s3://bucket-name/${line}"  --storage-class=STANDARD --force-glacier-transfer
done < xaa
``` 
8. The restored objects will remain in STANDARD class for the number of --restore-days mentioned in s3cmd restore command. After that they will be moved back to GLACIER. 
