/*
From: "Donald Schulz" <d.schulz@gmx.de>
To: <music-dsp@shoko.calarts.edu>
Subject: [music-dsp] Image-mirror method source code
Date: Sun, 11 Jun 2000 15:01:51 +0200

A while ago I wrote a program to calculate early echo responses.
As there seems to be some interest in this, I now post it into the
public domain.

Have phun,

Donald.
*/

/*

i have taken the liberty of renaming some of donald's variables to make 
his code easier to use for english speaking, non-german speakers. i did 
a simple search and replace on all the german words mentioned in the 
note below. all of the comments are still in german, but the english 
variable names make the code easier to follow, at least for me. i don't
think that i messed anything up by doing this, but if something's not
working you might want to try the original file, just in case.

douglas

*/

/****************************************************************************
 *
 * Early Echo Computation using image-mirror method
 *
 * Position of listener, 2 sound-sources, room-size may be set.
 * Four early echo responses are calculated (from left sound source and
 * right sound source to left and right ear). Angle with which the sound
 * meets the ears is taken into account.
 * The early echo response from left sound source to left ear is printed
 * to screen for demonstration, the first table contains the delay times
 * and the second one the weights.
 *
 * Program is released into the public domain.
 *
 * Sorry for german comments :-(
 * Some frequently used german words:
 * hoerpos : listening position
 * breite : width
 * laenge : length
 * hoehe : height
 * daempfung : damping
 * links : left
 * rechts : right
 * Ohr    : ear
 * Winkel : angle
 * Wichtung : weight
 * Normierung : normalization
 *
 *
 * If someone does some improvements on this, I (Donald, d.schulz@gmx.de)
 * would be happy to get the improved code.
 *
 ***************************************************************************/



#include <math.h>
#include <stdio.h>

#define early_length 0x4000     /* Length der Puffer fuer early-echo */
#define early_length_1 0x3fff

#define early_tap_num 20        /* Anzahl an early-echo taps */

#define width 15.0              /* 15 m widthr Raum (x)*/
#define length 20.0             /* 20 m lang (y) */
#define height 10.0               /* 10 m hoch (z)*/
#define damping 0.999         /* Dampingsfaktor bei Reflexion */

#define listening_positionx 7.91            /* hier sitzt der Hoerer (linkes ear) */
#define listening_positiony 5.0
#define listening_positionz 2.0

#define leftposx 5.1            /* hier steht die linke Schallquelle */
#define leftposy 16.3
#define leftposz 2.5

#define rightposx 5.9            /* hier steht die rechte Schallquelle */
#define rightposy 6.3
#define rightposz 1.5

#define i_length 32             /* Length des Eingangs-Zwischenpuffers */
#define i_length_1 31
#define o_length 32             /* Length des Ausgangs-Zwischenpuffers */
#define o_length_1 31


float *early_l2l;  /* linker Kanal nach linkem ear */
float *early_l2r;  /* linker Kanal nach rechtem ear */
float *early_r2l;  /* rechter Kanal nach linkem ear */
float *early_r2r;  /* rechter Kanal nach rechtem ear */

int early_pos=0;

int e_delays_l2l[early_tap_num];       /* Delays der early-echos */
float e_values_l2l[early_tap_num];     /* Geweighten der delays */
int e_delays_l2r[early_tap_num];
float e_values_l2r[early_tap_num];
int e_delays_r2l[early_tap_num];
float e_values_r2l[early_tap_num];
int e_delays_r2r[early_tap_num];
float e_values_r2r[early_tap_num];


/* Early-echo Berechnung mittels Spiegelquellenverfahren

Raummodell:
H - Hoererposition
L - Spiegelschallquellen des linken Kanales
U - Koordinatenursprung
Raum sei 11 meter breit und 5 meter lang (1 Zeichen = 1 meter)
Linker Kanal stehe bei x=2  y=4  z=?
Hoerer stehe bei x=5 y=1 z=?
___________________________________________________________________
|          |         |         |          |         |         |
|          |         |         |          |         |         |
|          |         |         |          |         |         |
|          |         |         |          |         |         |
__L___L________________L___L________________L___L________________L_
L | L        |       L | L       |        L | L       |        L|
|          |         |         |          |         |         |
|          |         |         |          |         |         |
|          |         |    H    |          |         |         |
_________________________X_________________________________________
|          |         |         |          |         |         |
|          |         |         |          |         |         |
|          |         |         |          |         |         |
|          |         |         |          |         |         |
__L___L________________L___L_________________L__L________________L_
*/

main()
{
  int i,j,select;
  float dist_max;
  float x,y,z,xref,yref,zref;
  float x_pos,y_pos,z_pos;
  float distance,angle;
  float weight;
  float normalizationr,normalizationl;
  
  
  early_l2l=(float *)malloc(early_length*sizeof(float));
  early_l2r=(float *)malloc(early_length*sizeof(float));;
  early_r2l=(float *)malloc(early_length*sizeof(float));;
  early_r2r=(float *)malloc(early_length*sizeof(float));;
  
  
  /* Erst mal Echos loeschen: */
  for (i=0;i<early_length;i++)
  early_l2l[i]=early_l2r[i]=early_r2l[i]=early_r2r[i]=0.0;
  
  dist_max=300.0*early_length/44100.0;  /* 300 m/s Schallgeschwindigkeit */
  
  /* Echo vom LINKEN Kanal auf linkes/rechtes ear berechnen */
  
  for (x=-ceil(dist_max/(2*length));x<=ceil(dist_max/(2*length));x++)
  for (y=-ceil(dist_max/(2*width));y<=ceil(dist_max/(2*width));y++)
  for (z=-ceil(dist_max/(2*height));z<=ceil(dist_max/(2*height));z++)
  {
    xref=2*x*width;
    yref=2*y*length;
    zref=2*z*height;
    for (select=0;select<8;select++)   /* vollstaendige Permutation */
    {
      if (select&1) x_pos=xref+leftposx;
      else x_pos=xref-leftposx;
      if (select&2) y_pos=yref+leftposy;
      else y_pos=yref-leftposy;
      if (select&4) z_pos=zref+leftposz;
      else z_pos=zref-leftposz;
      /* Jetzt steht die absolute Position der Quelle in ?_pos */
      
      /* Relative Position zum linken ear des Hoerers bestimmen: */
      x_pos-=listening_positionx;
      y_pos-=listening_positiony;
      z_pos-=listening_positionz;
      
      
      distance=sqrt(pow(x_pos,2)+pow(y_pos,2)+pow(z_pos,2));
      /* distance*147 = distance/300[m/s]*44100[ATW/s]; bei 32kHZ-> *106 */
      if ((distance*147)<early_length)
      {
        /* Einfallsangle im Bereich -Pi/2 bis Pi/2 ermitteln: */
        angle=atan(y_pos/x_pos);
        if (y_pos>0)   /* Klang kommt aus vorderem Bereich: */
        {  /* 0=left=>Verstaerkung=1 Pi=right=>Verstaerkung=0.22 (?) */
          angle+=3.1415926/2;     weight = 1 - angle/4;
        }
        else            /* Klang kommt von hinten: */
        {
          angle-=3.1415926/2;  weight= 1 + angle/4;
        }
        /* Early-echo gemaess angle und Entfernung gewichten: */
        early_l2l[(int) (distance*147.)]+=weight/(pow(distance,3.1));
      }
      
      /* Relative Position zum rechten ear des Hoerers bestimmen: */
      x_pos-=0.18;  /* Kopf ist 18 cm breit */
      
      distance=sqrt(pow(x_pos,2)+pow(y_pos,2)+pow(z_pos,2));
      /* distance*147 = distance/300[m/s]*44100[ATW/s]; bei 32kHZ-> *106 */
      if ((distance*147)<early_length)
      {
        /* Einfallsangle im Bereich -Pi/2 bis Pi/2 ermitteln: */
        angle=atan(y_pos/x_pos);
        if (y_pos>0)   /* Klang kommt aus vorderem Bereich: */
        {  /* 0=left=>Verstaerkung=1 Pi=right=>Verstaerkung=0.22 (?) */
          angle-=3.1415926/2;     weight = 1 + angle/4;
        }
        else            /* Klang kommt von hinten: */
        {
          angle+=3.1415926/2;  weight= 1 - angle/4;
        }
        /* Early-echo gemaess angle und Entfernung gewichten: */
        early_l2r[(int) (distance*147.)]+=weight/(pow(distance,3.1));
      }
    }
  }
  
  /* Echo vom RECHTEN Kanal auf linkes/rechtes ear berechnen */
  
  for (x=-ceil(dist_max/(2*length));x<=ceil(dist_max/(2*length));x++)
  for (y=-ceil(dist_max/(2*width));y<=ceil(dist_max/(2*width));y++)
  for (z=-ceil(dist_max/(2*height));z<=ceil(dist_max/(2*height));z++)
  {
    xref=2*x*width;
    yref=2*y*length;
    zref=2*z*height;
    for (select=0;select<8;select++)   /* vollstaendige Permutation */
    {
      if (select&1) x_pos=xref+rightposx;
      else x_pos=xref-rightposx;
      if (select&2) y_pos=yref+rightposy;
      else y_pos=yref-rightposy;
      if (select&4) z_pos=zref+rightposz;
      else z_pos=zref-rightposz;
      /* Jetzt steht die absolute Position der Quelle in ?_pos */
      
      /* Relative Position zum linken ear des Hoerers bestimmen: */
      x_pos-=listening_positionx;
      y_pos-=listening_positiony;
      z_pos-=listening_positionz;
      
      
      distance=sqrt(pow(x_pos,2)+pow(y_pos,2)+pow(z_pos,2));
      /* distance*147 = distance/300[m/s]*44100[ATW/s]; bei 32kHZ-> *106 */
      if ((distance*147.)<early_length)
      {
        /* Einfallsangle im Bereich -Pi/2 bis Pi/2 ermitteln: */
        angle=atan(y_pos/x_pos);
        if (y_pos>0)   /* Klang kommt aus vorderem Bereich: */
        {  /* 0=left=>Verstaerkung=1 Pi=right=>Verstaerkung=0.22 (?) */
          angle+=3.1415926/2;     weight = 1 - angle/4;
        }
        else            /* Klang kommt von hinten: */
        {
          angle-=3.1415926/2;  weight= 1 + angle/4;
        }
        /* Early-echo gemaess angle und Entfernung gewichten: */
        early_r2l[(int) (distance*147.)]+=weight/(pow(distance,3.1));
      }
      
      
      /* Und jetzt Early-Echo zweiter Kanal auf LINKES ear berechnen */
      x_pos-=0.18; /* Kopfwidth addieren */
      
      distance=sqrt(pow(x_pos,2)+pow(y_pos,2)+pow(z_pos,2));
      /* distance*147 = distance/300[m/s]*44100[ATW/s]; bei 32kHZ-> *106 */
      if ((distance*147)<early_length)
      {
        /* Einfallsangle im Bereich -Pi/2 bis Pi/2 ermitteln: */
        angle=atan(y_pos/x_pos);
        if (y_pos>0)   /* Klang kommt aus vorderem Bereich: */
        {  /* 0=left=>Verstaerkung=1 Pi=right=>Verstaerkung=0.22 (?) */
          angle-=3.1415926/2;     weight = 1 + angle/4;
        }
        else            /* Klang kommt von hinten: */
        {
          angle+=3.1415926/2;  weight= 1 - angle/4;
        }
        /* Early-echo gemaess angle und Entfernung gewichten: */
        early_r2r[(int) (distance*147.)]+=weight/(pow(distance,3.1));
      }
    }
  }
  
  
  /* Und jetzt aus berechnetem Echo die ersten early_tap_num Werte holen */
  /* Erst mal e's zuruecksetzen: */
  for (i=0;i<early_tap_num;i++)
  {
    e_values_l2l[i]=e_values_l2r[i]=0.0;
    e_delays_l2l[i]=e_delays_l2r[i]=0;  /* Unangenehme Speicherzugriffe vermeiden */
    e_values_r2l[i]=e_values_r2r[i]=0.0;
    e_delays_r2l[i]=e_delays_r2r[i]=0;
  }
  
  /* und jetzt e_delays und e_values extrahieren: */
  j=0;
  normalizationl=normalizationr=0.0;
  for(i=0;i<early_length;i++)
  {
    if (early_l2l[i]!=0)
    {
      e_delays_l2l[j]=i;
      e_values_l2l[j]=early_l2l[i];
      normalizationl+=early_l2l[i];
      j++;
    }
    if (j==early_tap_num) break;
  }
  j=0;
  for(i=0;i<early_length;i++)
  {
    if (early_l2r[i]!=0)
    {
      e_delays_l2r[j]=i;
      e_values_l2r[j]=early_l2r[i];
      normalizationr+=early_l2r[i];
      j++;
    }
    if (j==early_tap_num) break;
  }
  j=0;
  for(i=0;i<early_length;i++)
  {
    if (early_r2l[i]!=0)
    {
      e_delays_r2l[j]=i;
      e_values_r2l[j]=early_r2l[i];
      normalizationl+=early_r2l[i];
      j++;
    }
    if (j==early_tap_num) break;
  }
  j=0;
  for(i=0;i<early_length;i++)
  {
    if (early_r2r[i]!=0)
    {
      e_delays_r2r[j]=i;
      e_values_r2r[j]=early_r2r[i];
      normalizationr+=early_r2r[i];
      j++;
    }
    if (j==early_tap_num) break;
  }
  
  /* groessere von beiden normalizationen verwenden: */
  if (normalizationr>normalizationl) normalizationr=normalizationl;
  
  for (j=0;j<early_tap_num;j++)
  {
    e_values_l2l[j]/=normalizationr;
    e_values_l2r[j]/=normalizationr;
    e_values_r2l[j]/=normalizationr;
    e_values_r2r[j]/=normalizationr;
  }
  /* Ausgeben nur der l2l-Werte fuer schnelles Reverb */
  printf("int e_delays[%d]={",early_tap_num);
  for (j=0;j<(early_tap_num-1);j++)
    printf("%d, ",e_delays_l2l[j]);
  printf("%d};\n\n",e_delays_l2l[j]);
  
  printf("float e_values[%d]={",early_tap_num);
  for (j=0;j<(early_tap_num-1);j++)
    printf("%0.4f, ",e_values_l2l[j]);
  printf("%0.4f};\n\n",e_values_l2l[j]);

}



