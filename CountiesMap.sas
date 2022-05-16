DATA Pres (drop = office party version); 
	Infile "/home/u45007217/STS_2920/Project/countypres_2000-2016.csv" dsd firstobs = 2;
	INPUT year  state : $15. state_po $ county : $15. FIPS office : $10. candidate : $15.
	       party : $10. candidatevotes  totalvotes version; 
Run;
	
*Only concerned with data from 2016;	
DATA President_2016;
	Set Pres;
	Where year = 2016;  
	If FIPS = '.' THEN delete;
Run;

*Again, we must seperate data from Trump and Clinton;
	
Data Trump(RENAME= (candidatevotes = trump_votes) Drop = candidate) ; 
	Set President_2016;
	Where candidate = "Donald Trump";
	Percentage_Trump = candidatevotes/totalvotes * 100;
Run;

Data Clinton(KEEP = FIPS  candidatevotes  percentage_clinton); 
	Set President_2016; 
	Where candidate = "Hillary Clinton";
	Percentage_Clinton = candidatevotes/totalvotes *100;
Run;

Data Clinton(Rename= (candidatevotes = clinton_votes));
	SET clinton;
Run;	


/*Merging Data*/
PROC SORT DATA = TRUMP;
	BY FIPS; 
Run;	

PROC SORT DATA = Clinton; 
	By FIPS; 
run;

DATA Clinton_v_Trump; 
	MERGE Trump Clinton;  
	BY FIPS; 
Run;
	
*Obtaining margins for each county in terms of Trump;
DATA County_margins (keep = FIPS Trump_margin); 
	Set clinton_v_trump; 
	Trump_margin = percentage_trump - percentage_clinton;
	Label Trump_margin = "Winner";
Run;

*We need map.uscounty in terms of 5 digit FIPS number
Delete Alaska and Hawaii;
DATA Maps_Counties; 
	SET Maps.uscounty;
	FIPS = (state*1000 + county);
	if state = 2 Then delete;
		Else if state = 15 Then delete;
Run;


*PROC Format to get winner of each state and percentage tier;
proc format;
value margins
-100 - -10  = 'Clinton: Greater than 10%'
-10 - 0 = 'Clinton: Less than 10%'
0 - 10 = 'Trump: Less than 10%'
10 - 100 = 'Trump: Greater then 10%'
;
run;	


* fill patterns for the map areas;
pattern1 v=s c= bib;
pattern2 v=s c= cornflowerblue;
pattern3 v=s c= salmon;
pattern4 v=s c= red;
proc gmap
data= county_margins
map= maps_counties;
id FIPS;
choro trump_margin / discrete coutline=black;
format  trump_margin margins.;
run;
quit;




/*Arizona 2016 election*/

*Arizona margin of victory;
DATA AZ_margins; 
	Set county_margins;
	If FIPS >= 4000 AND FIPS < 5000;
Run;	

*Only concerned with AZ state map;
Data AZMap;
	Set maps_counties; 
	If FIPS >=4000 AND FIPS < 5000; 
Run;	
 
 
pattern1 v=s c= bib;
pattern2 v=s c= cornflowerblue;
pattern3 v=s c= salmon;
pattern4 v=s c= red; 
proc gmap
data = AZ_margins
map = AZMap;
id FIPS; 
choro trump_margin /discrete; 
format trump_margin margins.;
run;
quit;



*PA margin of victory;
DATA PA_margins; 
	Set county_margins;
	If FIPS >= 42000 AND FIPS < 43000;
Run;	

*Only concerned with PA state map;
Data PaMap;
	Set maps_counties; 
	If FIPS >=42000 AND FIPS < 43000; 
Run;	

 
 
pattern1 v=s c= bib;
pattern2 v=s c= cornflowerblue;
pattern3 v=s c= salmon;
pattern4 v=s c= red; 
proc gmap
data = Pa_margins
map = PaMap;
id FIPS; 
choro trump_margin /discrete; 
format trump_margin margins.;
run;
quit;



*NC margin of victory;
DATA NC_margins; 
	Set county_margins;
	If FIPS >= 37000 AND FIPS < 38000;
Run;	

*Only concerned with NC state map;
Data NCMap;
	Set maps_counties; 
	If FIPS >=37000 AND FIPS < 38000; 
Run;	

 
 
pattern1 v=s c= bib;
pattern2 v=s c= cornflowerblue;
pattern3 v=s c= salmon;
pattern4 v=s c= red; 
proc gmap
data = NC_margins
map = NCMap;
id FIPS; 
choro trump_margin /discrete; 
format trump_margin margins.;
run;
quit;



