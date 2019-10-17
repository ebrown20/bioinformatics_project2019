rm mcrA*
rm hsp70*
rm pH*
#put all mcrAgenomes in one file
for file in ref_sequences/mcrA*.fasta
do
 cat $file >> mcrAgeneALL.fasta
done

#put all hsp70genomes in one file
for file in ref_sequences/hsp70*.fasta
do
 cat $file >> hsp70geneALL.fasta
done

#first aligns the mcrA sequences using muscle and then uses hmmbuild to spit out a hidden markup m  
./../Private/bin/muscle3.8.31_i86linux64 -in mcrAgeneALL.fasta -out mcrAgeneAligned.fasta
./../Private/bin/hmmbuild mcrAgeneSequence.fasta mcrAgeneAligned.fasta

#first aligns the hsp70gene sequences using muscle then uses hmmbuild to spit out a hidden markup m 
./../Private/bin/muscle3.8.31_i86linux64 -in hsp70geneALL.fasta -out hsp70geneAligned.fasta
./../Private/bin/hmmbuild hsp70geneSequence.fasta hsp70geneAligned.fasta

for file in proteomes/proteome*.fasta
do
 filename=$(echo $file | cut -d / -f 2)
 ./../Private/bin/hmmsearch -o mcrAgeneFound_$filename mcrAgeneSequence.fasta $file
 hits=$(grep 'No hits' mcrAgeneFound_$filename | wc -l)
 if [ $hits -gt 0 ]
 then
  rm mcrAgeneFound_$filename
 fi
 if [ $hits -eq 0 ]
 then
  echo $filename >> mcrAgeneFound.txt
  rm mcrAgeneFound_$filename
  for line in $filename
  do
   ./../Private/bin/hmmsearch -o hsp70geneFound_$line hsp70geneSequence.fasta proteomes/$line
  hsphits=$(grep 'No hits' hsp70geneFound_$line | wc -l)
  if [ $hsphits -gt 0 ]
  then
   rm hsp70geneFound_$line
  fi
  done
  if [ $hsphits -eq 0 ]
  then
   echo $line >> hsp70geneFound.txt
   grep 'Domain search space' hsp70geneFound_$line | tr -s ' ' | cut -d ' ' -f 5 >> hsp70geneFound.txt
   rm hsp70geneFound_$line
  fi
 fi
done

grep 'proteome' hsp70geneFound.txt | sed s/'.fasta'/''/g > pH-resistant_methanogens.txt
