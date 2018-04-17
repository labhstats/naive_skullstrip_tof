#!/bin/bash

# skullstrip tof images using mask in MNI space
# and affine transform 


mni_brainmask=/home/lars/Desktop/Skullstrip/tof_brainmask.nii.gz
imDir=/media/lars/LaCie/working_tof_t1
tofImages=$(find $imDir -name 3d_tof.nii)

# loop over tof
for tof in ${tofImages[@]}; do
    echo $tof
    # calculate  MNI -> TOF transform
    tofdir=$(dirname $tof)
    matFile=${tofdir}/mni_to_native.mat
    # apply transform to ROI
    native_brainmask=${tofdir}/tof_brainmask.nii.gz
    tmp_mask=$(tempfile).nii.gz
    flirt -in $mni_brainmask -ref $tof -out $tmp_mask -init $matFile -applyxfm
    fslmaths $tmp_mask -bin $native_brainmask
    rm $tmp_mask 
    # multiply tof with mask
    tof_skullstrip=${tofdir}/tof_brain.nii.gz
    fslmaths $tof -mul $native_brainmask $tof_skullstrip
done

