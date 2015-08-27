M0=load('all_accuracies.txt')
M=M0
[m,n]=size(M)
if isvector(M)
    Average=M
    StandardError=zeros(1,n)
else
    Average=mean(M)
    StandardError=std(M)/sqrt(m)
end



OutputMatrix=zeros(3,n)
OutputMatrix(1,:)=[1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 30 40 50 60 70 80 90 100 108]
OutputMatrix(2,:)=Average
OutputMatrix(3,:)=StandardError

OutputMatrix1=OutputMatrix'


dlmwrite('averagedAcc.gp',OutputMatrix1,'delimiter','\t','precision','%.6f')

plot(OutputMatrix(1,:),OutputMatrix(2,:),'-o')
