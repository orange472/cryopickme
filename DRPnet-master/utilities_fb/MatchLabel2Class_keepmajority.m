function [label2class,GT,class_im,class_rgb]=MatchLabel2Class_keepmajority(labels,GT_RGB)
%--------------------------------------------------------------------------
% classes ------> new class
% -1: mixed      -2        
%  0: ignore      0   
%  1: epi-stroma -1   
%  2: epi-stroma +1   

% given partition labels and GT image find best matches for each partition
[GT]=ConvertGT(GT_RGB);
%--- Match GroundTruth to Region Labels   
[label2class0,n12,n1,n2]=LabelCooccurence(labels,GT,ones(size(labels)));

%--- best matches    
label2class=RefineLabel2Class_keepmajority(label2class0,1);
%    label2class : only positive labels (no class is assigned to label=0) 
[class_im,class_rgb]=mapclass2label(labels,label2class);


class=label2class(:,2);
class(class==-1)=-2;
class(class==1)=-1;
class(class==2)=+1;
label2class(:,2)=class;

