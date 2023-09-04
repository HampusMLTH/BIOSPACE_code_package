# BIOSPACE_code_package
Matlab code for analysis of BIOSPACE measurements
Scripts for reading and evaluating the data for BIOSAPCE
Author: Hampus Manefjord 2023
Licence: CC BY 2.0 https://creativecommons.org/licenses/by/2.0/
You are free to:
Share and copy and redistribute the material in any medium or format
Adapt and remix, transform, and build upon the material for any purpose, even commercially.
Under the following terms:
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made.
For example consider citing my work or reaching out to hampus.manefjord @forbrf.lth.se

% Reading the data from the folder structure stored by BIOSPACE
this takes some time if the folders are large
First the reference is read or loaded (this is typically only needed once per instrument)
The foldername of a measurement along with the output from the reference is sent into read_biospace_data
In the case of [pre april 2022] biospace code, separate copol and depol
measurements are read and then merged
the biospace_data.data is ordered: 
[y x wavelength scatter_angles yaw_angles roll_angles polarization_angle]

To get access to the raw data used for
these examples, download using these links, reach out to me if they have
expired
Download link: https://lunduniversityo365-my.sharepoint.com/:f:/g/personal/ha0261ma_lu_se/Eidnpf9DN7BPkN0NZ3Jc7mUBwOq1WNQvu6dQdncnVGnhkw?e=1bRvR4
