rm mcrA*
rm hsp70*
rm pH-resistant_methanogens.txt
rm allProteomes.txt
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

#sets headers for output files
echo -e "proteome name \t mcrAgene count \t hsp70gene count" >> allProteomes.txt
echo -e "------------- \t -------------- \t ---------------" >> allProteomes.txt
echo "Names of the candidate pH-resistant methanogens: " >> pH-resistant_methanogens.txt
echo " " >> pH-resistant_methanogens.txt

#loops through all proteomes in the proteomes folder
for file in proteomes/proteome*.fasta
do
 #extracts the proteome part of the file name
 filename=$(echo $file | cut -d / -f 2)
 #searches for an mcrAgene in each proteome file
 ./../Private/bin/hmmsearch -o mcrAgeneFound_$filename mcrAgeneSequence.fasta $file
 mcrAhits=$(grep 'Domain search space' mcrAgeneFound_$filename | tr -s ' ' | cut -d ' ' -f 5)
 ./../Private/bin/hmmsearch -o hsp70geneFound_$filename hsp70geneSequence.fasta $file
 hsp70hits=$(grep 'Domain search space' hsp70geneFound_$filename | tr -s ' ' | cut -d ' ' -f 5)

 #puts all proteomes and numbers of mcrA and hsp70 genes found in each proteome
 echo -e "$filename \t \t $mcrAhits \t \t \t $hsp70hits" | sed s/'.fasta'/''/g >> allProteomes.txt
 rm mcrAgeneFound_$filename
 rm hsp70geneFound_$filename

 #if a pH-resistant methanogen, i.e. has both mcrA and hsp70 genes, add to file
 if [ $mcrAhits -gt 0 ]
 then
  if [ $hsp70hits -gt 0 ]
  then
   echo $filename | sed s/'.fasta'/''/g >> pH-resistant_methanogens.txt
  fi
 fi
done


