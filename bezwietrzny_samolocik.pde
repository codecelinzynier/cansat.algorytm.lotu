PGraphics circles;
PGraphics my_line;
PGraphics mapa;

int c = 128;

//mapa rozmiar i położenie
int mapa_szer = 700;
int mapa_wys  = 700;
int mapa_pocz_x = 10;
int mapa_pocz_y = 10;
int ostatnio_na_planszy = 0;
float kursor_pocz_x = random(100, 600);
float kursor_pocz_y = random(100, 600);
float cel_x = 350;
float cel_y = 350;
float x_do_celu;
float y_do_celu;
float linka_P = 1;  //więcej = bardziej pociągnięta linka
float linka_L = 1;
float wspolczynnik_predkosci = 1;
float wspolczynnik_obrotu = 1.2;
float rysowany_x = 0;
float rysowany_y = 0;                 //rysowane tymczasowe ostatnie punkty
float licznik = 0;                    //licznik ilości ruchów
float azymut_na_cel = 0;              //azymut kierunkowy na cel dla CanSat'a 
float azymut2;
float oczekiwany_azymut = 0;
float odwrotnosc_oczekiwanego_azymutu = 0; 
float wskaznik = 0;                   
float odleglosc_od_celu_x = 0;
float odleglosc_od_celu_y = 0;
float cwiartki = 0;
float kontrolka = 0;
float wysokosc = 1300;
float[] dane_azymut = {0};            //lista kątów obrotu z każdym krokiem
float[] dane_przesuniecie = {0};     //lista przesunięć w poszczególnych ruchach



//rozdielczość ekranu laptopa 1366 x 768


//tworzymy mapę
void mapa_ini(int szer, int wys)
{
  mapa = createGraphics(szer, wys); 
  
  //początek renderowania obiektu
  mapa.beginDraw();
  
  //tło 
  mapa.background(0, 0, 0, 255);
  
  //linie podziałki
  mapa.stroke(255, 0, 0, 80);
  //pionowe
  for(int x=0; x<szer; x+=20) mapa.line(x, 1, x, mapa_wys-2);
  //pioziome
  for(int y=0; y<wys; y+=20)  mapa.line(1, y, mapa_szer-2, y);

  //ramka
  mapa.stroke(255, 255, 255, 255);
  mapa.line(0, 0, szer-1, 0);
  mapa.line(0, 0, 0, wys-1);
  mapa.line(szer-1, 0, szer-1, wys-1);
  mapa.line(0, wys-1, szer-1, wys-1);  

  //koniec renderowania obiektu
  mapa.endDraw();
  
}



void setup() 
{
  

  
  size(1200, 780);
  
  frameRate(15);
  
  background(0);
  
  
  mapa_ini(mapa_szer, mapa_wys);
  
  /*
  //Przygotuj obiekt 
  circles = createGraphics(100, 100); 
  circles.beginDraw();
  circles.background(255, 0, 0, 255);
  circles.noStroke();    //bez obramowania
  circles.fill(0, 0, 255, 255); 
  circles.endDraw();
  
  
  //
  my_line = createGraphics(130, 130); 
  my_line.beginDraw();
  my_line.stroke(255);
  my_line.background(128, 255);
  my_line.fill(255, 0, 0, 255); 
  my_line.endDraw();
 */
} 

boolean kursor_jest_na_mapie(int x, int y)
{
  noCursor();
  //jeśli pozycja myszki mieści się na mapie
  if(  x > mapa_pocz_x 
    && x < mapa_pocz_x + mapa_szer 
    && y > mapa_pocz_y 
    && y < mapa_pocz_y + mapa_wys 
    )
      return true;
    else
      return false;
}

void mapa_rysuj_kursor(int x, int y)
{
  //jeśli pozycja myszki mieści się na mapie
  if(kursor_jest_na_mapie(x, y))
  {
    line(mapa_pocz_x+1, y, mapa_pocz_x+mapa_szer-2, y);  //pozioma
    line(x, mapa_pocz_y+1, x, mapa_pocz_y+mapa_wys-2);   //pionowa
  }
  else 
    cursor();  //poza mapą - pokaż kursor myszki  noCursor();
    
}

void draw() {
  strokeWeight(2.5);
  //image(circles, 0, 0);
  //image(my_line, 50, 50);
  image(mapa, mapa_pocz_x, mapa_pocz_y);
  
  stroke(255);
  
  mapa_rysuj_kursor(mouseX, mouseY);
  
  //Prezentuj wsp X
  //wykasuj obszar na text
  noStroke();
  fill(0);
  rect(mapa_szer+20, 0, width, 33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("prędkość" + dane_przesuniecie[dane_przesuniecie.length - 1], mapa_szer+20, 30); 
  
  //Prezentuj wsp Y
  //wykasuj obszar na text
  noStroke();
  fill(0);
  rect(mapa_szer+20, 35, width, 35+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("wskaźnik " + wspolczynnik_obrotu, mapa_szer+20, 35+30); 

   noStroke();
  fill(0);
  rect(mapa_szer+20, 70, width, 70+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("azymut_cansata " + dane_azymut[dane_azymut.length - 1], mapa_szer+20, 70+30); 
 
  noStroke();
  fill(0);
  rect(mapa_szer+20, 105, width, 105+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("jeszcze_nic " + azymut_na_cel, mapa_szer+20, 105+30);  
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 140, width, 140+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("różnica_x " + rysowany_x, mapa_szer+20, 140+30);
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 175, width, 175+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("różnica_y " + rysowany_y, mapa_szer+20, 175+30);
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 210, width, 210+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("azymut_od_środka " + oczekiwany_azymut, mapa_szer+20, 210+30);
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 245, width, 245+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("x_od_środka " + x_do_celu, mapa_szer+20, 245+30);
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 280, width, 280+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("y_do_środka " + y_do_celu, mapa_szer+20, 280+30);
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 315, width, 315+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("linka_P " + linka_P, mapa_szer+20, 315+30);
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 350, width, 350+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("linka_L " + linka_L, mapa_szer+20, 350+30);
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 385, width, 385+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("odwrotnosc " + odwrotnosc_oczekiwanego_azymutu, mapa_szer+20, 385+30);
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 420, width, 420+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("azymut2 " + azymut2, mapa_szer+20, 420+30);
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 455, width, 455+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("ćwiartki " + cwiartki, mapa_szer+20, 455+30);
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 490, width, 490+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text("wysokość " + wysokosc, mapa_szer+20, 490+30);

    //rysowanie linii
    stroke(155, 155, 155);
    pushMatrix();
    translate(kursor_pocz_x, kursor_pocz_y);
    rotate(radians(270));
    rysowany_x = 0;
    rysowany_y = 0;
    for(int i = 1; i < dane_azymut.length; i++)
    {
        rotate(radians(dane_azymut[i]));      //rysowanie matrixami
        line(0, 0, dane_przesuniecie[i], 0);
        translate(dane_przesuniecie[i], 0);
        rotate(radians(360 - dane_azymut[i]));
        stroke(255, 155, 155);
        //line(rysowany_x, rysowany_y, sin(radians(dane_azymut[dane_azymut.length - 1])) * dane_przesuniecie[dane_przesuniecie.length - 1], cos(radians(dane_azymut[dane_azymut.length - 1])) * dane_przesuniecie[dane_przesuniecie.length - 1]);//rysowanie trygonometrią
        rysowany_x = rysowany_x + sin(radians(dane_azymut[i])) * dane_przesuniecie[i];
        rysowany_y = rysowany_y + cos(radians(dane_azymut[i])) * dane_przesuniecie[i];
    }
    //rysowanie wektoru
    strokeWeight(4);
    stroke(102, 255, 102);
    rotate(radians(dane_azymut[dane_azymut.length - 1]));
    line(0, 0, dane_przesuniecie[dane_przesuniecie.length - 1] * 25, 0);
    line(dane_przesuniecie[dane_przesuniecie.length - 1] * 25 - 10, 10, dane_przesuniecie[dane_przesuniecie.length - 1] * 25, 0);
    line(dane_przesuniecie[dane_przesuniecie.length - 1] * 25 - 10, -10, dane_przesuniecie[dane_przesuniecie.length - 1] * 25, 0);
    rotate(radians(360 - dane_azymut[dane_azymut.length - 1]));
    popMatrix();

  
  //rysowanie punktu celu
  strokeWeight(10);
  stroke(255, 0, 0);
  point(cel_x, cel_y);
  
  //stroke(0, 0, 10, 20);
  //fill(204, 102, 0);
  //rect(30, 20, 55, 35);
  
}

void mousePressed() {
  cel_x = mouseX;
  cel_y = mouseY;
} 


void mouseMoved() 
{
   
  //  rysowany_x  rysowany_y  dane_azymut  linka_P  linka_L  cel_x  cel_y  kursor_pocz_x  kursor_pocz_y  azymut_na_cel  

  
  x_do_celu = kursor_pocz_x + rysowany_x - cel_x;
  y_do_celu = kursor_pocz_y - rysowany_y - cel_y;
  
  oczekiwany_azymut = abs(degrees(atan(  y_do_celu / x_do_celu  )));
  
  
  
  
  
  
  /*
  if(x_do_celu <=  30 && x_do_celu >=  -30 && y_do_celu <=  30 && y_do_celu >= -30)
  {
    if(wysokosc > 0 && kontrolka == 0)
    {
      wspolczynnik_obrotu = 3;
      kontrolka = 1;
    }
  }
  else
  {
    wspolczynnik_obrotu = 1.2;
  }
  
  if(wysokosc == 0)
  {
    //koniec
  }*/
  if(x_do_celu <=  30 && x_do_celu >=  -30 && y_do_celu <=  30 && y_do_celu >= -30)
  {
    //nic
  }
  else
  {
    line(cel_x + x_do_celu, cel_y, cel_x + x_do_celu, cel_y + y_do_celu);
    line(cel_x, cel_y, cel_x + x_do_celu, cel_y);
    line(cel_x, cel_y, cel_x + x_do_celu, cel_y + y_do_celu);
    
    
    if(x_do_celu<=0 && y_do_celu<=0)
    {
      oczekiwany_azymut = (450 + oczekiwany_azymut) % 360;
      cwiartki = 4;
    }
    else if(x_do_celu>=0 && y_do_celu<=0)
    {
      oczekiwany_azymut = 270 - oczekiwany_azymut;
      cwiartki = 1;
    }
    else if(x_do_celu>=0 && y_do_celu>=0)
    {
      oczekiwany_azymut = 270 + oczekiwany_azymut;
      cwiartki = 2;
    }
    else if(x_do_celu<=0 && y_do_celu>=0)
    {
      oczekiwany_azymut = (450 - oczekiwany_azymut) % 360;
      cwiartki = 3;
    }
    
    if(oczekiwany_azymut <= 180)
    odwrotnosc_oczekiwanego_azymutu = 180 + oczekiwany_azymut;
    else
    odwrotnosc_oczekiwanego_azymutu = oczekiwany_azymut - 180;
    
    azymut2 = dane_azymut[dane_azymut.length - 1];
    if(azymut2 < oczekiwany_azymut && azymut2 > odwrotnosc_oczekiwanego_azymutu)
    {
      azymut2 = azymut2 + 360;
    }
    
    
  
    if(cwiartki == 1 || cwiartki == 2)
      {
        if(azymut2 > oczekiwany_azymut && azymut2 <= 360 || azymut2 < odwrotnosc_oczekiwanego_azymutu && azymut2 >= 0 )  
          {
            linka_L = linka_L + 0.2;
            linka_P = linka_P - 0.1;
            wskaznik = 1;
          }
          else
          {
            linka_P = linka_P + 0.2;
            linka_L = linka_L - 0.1;
            wskaznik = 2;
          }
      }
    else if(cwiartki == 3 || cwiartki == 4)
      {
        if(azymut2 > odwrotnosc_oczekiwanego_azymutu && azymut2 <= 360 || azymut2 < oczekiwany_azymut && azymut2 >= 0 )  
        {
          linka_P = linka_P + 0.2;
          linka_L = linka_L - 0.1;
          wskaznik = 2;
        }
        else
        {
          linka_L = linka_L + 0.2;
          linka_P = linka_P - 0.1;
          wskaznik = 1;
        }  
      }
      
    if(linka_P > 2)
    {
      linka_P = 2;
    }
    else if(linka_P < 0)
    {
      linka_P = 0;
    }
    
    if(linka_L > 2)
    {
      linka_L = 2;
    }
    else if(linka_L < 0)
    {
      linka_L = 0;
    }
    
    licznik++; 
    
      dane_azymut = append(dane_azymut, (dane_azymut[dane_azymut.length - 1] + (linka_P - linka_L) * wspolczynnik_obrotu) % 360);                //każdorazowa zmiana kąta w stopniach
      while(dane_azymut[dane_azymut.length - 1] < 0)
      {
      dane_azymut[dane_azymut.length - 1] = 360 + dane_azymut[dane_azymut.length - 1];
      }
      //dane_przesuniecie = append(dane_przesuniecie, (linka_P + linka_L) * wspolczynnik_predkosci);  //każdorazowe przesunięcie w pikselach
      dane_przesuniecie = append(dane_przesuniecie, 2 * wspolczynnik_predkosci); 
      if(wysokosc > 0)wysokosc = wysokosc - 2;
     
  }
}
