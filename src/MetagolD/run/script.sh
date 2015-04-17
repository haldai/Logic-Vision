


#../../../../../homes/dl308/yap-6/bin/yap
#YAP='/homes/dl308/yap-6/bin/yap'
YAP=yap

results_dir='./results'

rm -r ${results_dir} > /dev/null 2>&1
mkdir ${results_dir}


rm all_times.txt > /dev/null 2>&1
rm all_accuracies.txt > /dev/null 2>&1



for fold_index in 1 2 3 4 5 6 7 8 9 10
do
	echo ${fold_index}
	cat ../NELL/examples/test_${fold_index}.pl > ../NELL/testExs.pl
	for train_size in 1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 30 40 50 60 70 80 90 100 108
	do
		echo ${train_size}
		cat ../NELL/examples/train_${fold_index}_${train_size}.pl > ../NELL/trainExs.pl

		$YAP -L run.pl >> ${results_dir}/res_${fold_index}_${train_size}.pl


	cat onePA.pl >> all_accuracies.txt
    cat oneTime.pl >> all_times.txt
done
echo -e "\n" >> all_accuracies.txt
echo -e "\n" >> all_times.txt

done
#echo -e "\n" >> all_times.tx

matlab -nojvm -nodisplay -nodesktop -nosplash -logfile < average_time.m
matlab -nojvm -nodisplay -nodesktop -nosplash -logfile < average_accuracy.m
#$YAP -L average.pl
gnuplot plot_learning_curves_withErrorBar.gp > acc.eps

cp acc.eps ${results_dir}
cp all_accuracies.txt ${results_dir}
cp all_times.txt ${results_dir}
cp averagedAcc.gp ${results_dir}
cp averagedTime.gp ${results_dir}


