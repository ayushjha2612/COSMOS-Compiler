cp testing_parser testCases/
cd testCases
for file in *;do ./testing_parser <$file> output_$file;done
mkdir output
for file in output_*;do mv $file output/;done
mv output ..
rm testing_parser
cd ..
cp testing_parser genTestCases/
cd genTestCases
for file in *;do ./testing_parser <$file> gentest_output_$file;done
for file in gentest_output_*;do mv $file ../output/;done
rm testing_parser
cd ../output/
mkdir generator
mkdir manual
for file in gentest_output_*;do mv $file generator/;done
for file in output_*;do mv $file manual/;done