 clc;
close all;
clear all;
addpath libsvm-mat-2.88-1;

load PsePSSM_harmone_lg10;
%****************************************
 % data_scale=scaledata(PsePSSM_harmone_lg1,-1,1);
Result=0;
y=[];
Accuracy=0;
result=50;
Total_Seq_train=246;
DNA_labels=[];
Total_correct=0;
  c1=0; 
  c2=0;
  c3=0;
  c4=0;
 
  % Class labeling 
 
  DNA_labels(1:123)=1;
  DNA_labels(124:246)=2;
  %>>>>>>>>>>
  fold=5;
  single_fold = floor(Total_Seq_train/fold);
test_total = single_fold * fold;
remain = Total_Seq_train - test_total;

aaa=PsePSSM_harmone_lg10';

for k=1:30
  randperm_data=randperm(size(PsePSSM_harmone_lg10',2));
 ind=randperm_data;
  feature1=aaa(:,ind);
    permut_labels=DNA_labels(ind);
      aa=find(permut_labels(1:246)==1);
      bb=find(permut_labels(1:246)==2);
  %+++++++++++++++++++++++++++++  train label
  Yout=[];
 Labelstem=[];
 Samplestem=[];
 Samplestem=feature1';
Labelstem= permut_labels';
m = single_fold;
l=1;
A = 1;
        C = 0;

        for T = 1:fold
            C = C + 1;
               T

                if T == 1

                Samples=Samplestem(A + single_fold:end,:)';

                TestSample=Samplestem(1:single_fold,:)';

                Labels=Labelstem(A + single_fold:end,:)';

                TestLabel=Labelstem(1: single_fold,:)';
                A = single_fold;

                else
                    if C == fold
                        s11=Samplestem(1:A,: ); % Jackknifing 
                        l11=Labelstem(1:A,: );

                        Samples=s11';
                        Labels=l11';

                        TestSample=Samplestem(A + 1: end,:)';

                        TestLabel=Labelstem(A + 1: end,:)'; 
                    else
                        s11=Samplestem(1:A,: ); % Jackknifing 
                        l11=Labelstem(1:A,: );
                        A = single_fold;
                        A = T * A;
                        s22=Samplestem((A+1):end,:);
                        l22=Labelstem((A+1):end,:);


                        Samples=[s11;s22]';
                        Labels=[l11;l22]';

                        TestSample=Samplestem((A - single_fold)+ 1: A,:)';

                        TestLabel=Labelstem((A - single_fold)+ 1: A,:)';
                    end  
        end
    
    model = svmtrain(Labels', Samples',' -c 40 -g 0.2');
    
   [Predict_label,accuracy, dec_values] = svmpredict(TestLabel', TestSample', model);
 
    if C == fold
      Yout(l:m + remain) = Predict_label;

    else
        Yout(l:m) = Predict_label;
        l = m + 1;
        m =(T+1)* single_fold;

    end

        end
Yout=round(Yout);

yy(1:123)=Yout(aa);
yy(124:246)=Yout(bb);
%yy(193:400)=Yout(cc);
%yy(401:523)=Yout(dd);

Result=find(yy==DNA_labels);
   Total_correct=size(Result,2);
   Accuracy=(Total_correct/Total_Seq_train)*100

if (result< Accuracy)
    result=Accuracy;
    save prediction yy;
end
 end
 result

 
 %+++++++++++++++++ Performance Measure Calculation+++++++++++++++++++++
% for i=1:size(Protein_labels,2)
%     if Protein_labels(1,i)==1 && y(1,i)==1
%         TP=TP+1;
%     elseif Protein_labels(1,i)==2 && y(1,i)==2
%         TN=TN+1;
%     elseif Protein_labels(1,i)==1 && y(1,i)==2
%         FN=FN+1;
%     elseif Protein_labels(1,i)==2 && y(1,i)==1
%         FP=FP+1;
%     end
% end
% %++++++++++++++ Accuracy +++++++++++++++
% Acc=(TP+TN)/(TP+TN+FN+FP)*100
% 
% %++++++++++++++ Sensitivity ++++++++++++
% sen=TP/(TP+FN)*100
% 
% %++++++++++++++ Specificity +++++++++++++
% spe=TN/(TN+FP)*100
% 
% %+++++++++++++++ MCC ++++++++++++++++++
%     a=(TP+FN)*(TP+FP)*(TN+FN)*(TN+FP);
% MCC=((TP*TN)-(FN*FP))/sqrt(a)
% 
% %++++++++++++++++++ F-measrue++++++++++++
%     gh=(TP/(TP+FP)); %++++++++++ This is Precision
%     rh=(TP/(TP+FN));  % ++++++++ This is Recall
%     F=(gh*rh)/(gh+rh);
%     F_Measure=2*F
%  
% %+++++++++++++++ Precision & Recall +++++++++++
%     Precision=gh
%     Recall=rh