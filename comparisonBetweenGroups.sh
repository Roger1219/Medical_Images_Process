# bash
-gltLabel 1 StrabismusVsNormal -gltCode 1 'condition : 1*normal -1* strabismus: 1*pos -1*neg' 

-glfLabel 1 male_condXEmo -glfCode 1 'sex : 1*male condition : 1*face -1*house emotion : 1*pos -1*neg & 1*pos -1*neu' \
'condition : 1*normal -1*strabismus status : 1*convergence -1*relax'

-dataTable                                                                                     \
          Subj  condition   status   InputFile                               \
           XX   normal      convergence  stats.XX+tlrc'[1]'                 \
           XX   normal      relax  stats.XX+tlrc'[4]'                 \
           XX   strabismus  convergence  stats.XX+tlrc'[1]'                 \
           XX   strabismus  relax  stats.XX+tlrc'[4]'                 