cp testing_parser.out testCases/
mkdir output
cd testCases
for file in *.cos;do ./testing_parser.out $file;done
rm testing_parser.out
for file in *.txt;do mv $file ../output/;done
cd ..
