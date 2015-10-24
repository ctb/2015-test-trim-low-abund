NULLGRAPH=~/dev/nullgraph

all: simple-genome-reads.fa simple-genome-reads.mut.pos simple-genome-sam-mismatches.pos

simple-genome.fa:
	$(NULLGRAPH)/make-random-genome.py -l 1000 -s 1 > simple-genome.fa

simple-genome-reads.fa: simple-genome.fa
	$(NULLGRAPH)/make-reads.py -S 1 -e .01 -r 100 -C 100 simple-genome.fa --mutation-details simple-genome-reads.mut > simple-genome-reads.fa

simple-genome-reads.mut.pos: simple-genome-reads.fa
	./convert-mut-to-pos.py simple-genome-reads.mut simple-genome-reads.mut.pos

simple-genome-sam-mismatches.pos: simple-genome-reads.sam
	./sam-scan.py simple-genome.fa simple-genome-reads.sam -o simple-genome-sam-mismatches.pos

simple-genome-reads.sam: simple-genome-reads.fa.abundtrim
	bowtie2-build simple-genome.fa simple-genome > /dev/null
	samtools faidx simple-genome.fa

	bowtie2 -f -x simple-genome -U simple-genome-reads.fa.abundtrim -S simple-genome-reads.sam

simple-genome-reads.fa.abundtrim: simple-genome-reads.fa
	../scripts/trim-low-abund.py -M 1e7 -k 21 --diginorm simple-genome-reads.fa

report: all
	./summarize-pos-file.py simple-genome-sam-mismatches.pos simple-genome-reads.fa.abundtrim 
	./summarize-pos-file.py simple-genome-reads.mut.pos simple-genome-reads.fa
