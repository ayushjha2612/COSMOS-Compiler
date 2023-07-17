cp testing_parser.out testCases/
cd testCases
for file in *.cos;do cp $file $file.cpp ;done
for file in *.cpp;do g++ $file -o PREPROCESSED_$file.cos -E ;done
for file in *.cpp;do rm $file ;done
for file in PREPROCESSED_*;do ./testing_parser.out $file;done
rm testing_parser.out
for file in *.txt;do mv $file ../output/;done
for file in *.cpp;do mv $file ../output/;done
cd ..
# cp testing_parser.out testCases/
# cd testCases
# for file in *.cos;do ./testing_parser.out $file;done
# rm testing_parser.out
# for file in *.txt;do mv $file ../output/;done
# cd ..

