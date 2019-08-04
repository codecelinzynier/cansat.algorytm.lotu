PGraphics circles;
PGraphics my_line;
PGraphics mapa;

//mapa rozmiar i położenie
float mapa_szer = 700;
float mapa_wys  = 700;
float mapa_pocz_x = 10;
float mapa_pocz_y = 10;
float predkosc_x = 0;
float predkosc_zmiany_predkosci_x = 0;
float predkosc_y = 0;
float predkosc_zmiany_predkosci_y = 0;
int ponadczasowe_i = 0;
int nerwowosc_wiatru = 200;              //strowanie gwałtownością zmian wiatru - nie polecam stosować powyżej 1000 (liczby całkowite, musi być powyżej 0)
int czy_rysowac_sciezke = 1;             //czy rysować ścieżkę wiatru (0 = nie, 1 = tak) (w celu uniknięcia spadków FPS)

float[] dane_x = {0};                    //tu zapisywane są kolejne wartości x wiatru (wartoość wiatru x w tym momencie:  dane_x[dane_x.length - 1]   )
float[] dane_y = {0};                    //tu zapisywane są kolejne wartości y wiatru (wartoość wiatru y w tym momencie:  dane_y[dane_y.length - 1]   )
float[] dane_puste = {0};
void mapa_ini(float szer, float wys)
{
  mapa = createGraphics((int)szer, (int)wys); 
  
  //początek renderowania obiektu
  mapa.beginDraw();
  
  //tło 
  mapa.background(0, 0, 0, 255);
  
  //linie podziałki
  mapa.stroke(255, 0, 0, 80);
  //pionowe
  for(float x=0; x<szer; x+=20) mapa.line(x, 1, x, mapa_wys-2);
  //pioziome
  for(float y=0; y<wys; y+=20)  mapa.line(1, y, mapa_szer-2, y);

  //ramka
  mapa.stroke(255, 25, 25, 112);
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
  
  frameRate(1200);
  
  background(0);
  
  dane_x = append(dane_x, 400);
  
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

boolean kursor_jest_na_mapie(float x, float y)
{
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

void mapa_rysuj_kursor(float x, float y)
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
  text(mouseX, mapa_szer+20, 30); 
  
  //Prezentuj wsp Y
  //wykasuj obszar na text
  noStroke();
  fill(0);
  rect(mapa_szer+20, 35, width, 35+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text(mouseY, mapa_szer+20, 35+30); 
 
  
  noStroke();
  fill(0);
  rect(mapa_szer+20, 70, width, 70+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text(predkosc_x, mapa_szer+20, 70+30); 
    
  noStroke();
  fill(0);
  rect(mapa_szer+20, 105, width, 105+33);
  //pokaż wartość
  stroke(255);
  textSize(32);
  fill(0, 102, 153);
  text(predkosc_zmiany_predkosci_x, mapa_szer+20, 105+30);


  stroke(100, 100, 100);
  
  //rysowanie lini
  for(int i = 1; i < dane_x.length / 4; i++){
  if(czy_rysowac_sciezke == 1)line(dane_x[i] + 10, dane_y[i] + 10, dane_x[i-1] + 10, dane_y[i-1] + 10);
  ponadczasowe_i = i;
  }
  
  stroke(0, 255, 0);
  
  line(dane_x[ponadczasowe_i] + 10, dane_y[ponadczasowe_i] + 10, 360, 360);
  /*
  
  //rysowanie matrixami
  
  stroke(255, 0, 0);
  
  pushMatrix();
  
  translate(360, 360);
  
  rotate(atan(((350 - dane_y[dane_y.length - 1]) * -1) / (350 - dane_x[dane_x.length - 1])));
  
  line(0,0, 200, 0);
  
  //sqrt(sq(350 - dane_y[dane_y.length - 1]) + sq(350 - dane_x[dane_x.length - 1]))
  
  popMatrix();
  
  */
  
  for(int i = 0; i < nerwowosc_wiatru; i++){

  //zmiana parametrów x wiatru
  
  dane_x = append(dane_x, dane_x[dane_x.length - 1] + (350 - dane_x[dane_x.length - 1]) / 35 + predkosc_x / 1000); 
  predkosc_x = predkosc_x + (350 - dane_x[dane_x.length - 1]) / 50 + predkosc_zmiany_predkosci_x;
  if(predkosc_x > 10000)
  {
    predkosc_x = 10000;
  }
  else if(predkosc_x < -10000)
  {
   predkosc_x = -10000; 
  }
  predkosc_zmiany_predkosci_x = predkosc_zmiany_predkosci_x + random(-2, 2);
  if(predkosc_zmiany_predkosci_x > 20)
  {
    predkosc_zmiany_predkosci_x = 20;
  }
  else if(predkosc_zmiany_predkosci_x < -20)
  {
   predkosc_zmiany_predkosci_x = -20; 
  }
  
  //zmiana parametrów y wiatru
  
  dane_y = append(dane_y, dane_y[dane_y.length - 1] + (350 - dane_y[dane_y.length - 1]) / 35 + predkosc_y / 1000); 
  predkosc_y = predkosc_y + (350 - dane_y[dane_y.length - 1]) / 50 + predkosc_zmiany_predkosci_y;
  if(predkosc_y > 10000)
  {
    predkosc_y = 10000;
  }
  else if(predkosc_y < -10000)
  {
   predkosc_y = -10000; 
  }
  predkosc_zmiany_predkosci_y = predkosc_zmiany_predkosci_y + random(-2, 2);
  if(predkosc_zmiany_predkosci_y > 20)
  {
    predkosc_zmiany_predkosci_y = 20;
  }
  else if(predkosc_zmiany_predkosci_y < -20)
  {
   predkosc_zmiany_predkosci_y = -20; 
  }
  
  
  
  
  
}



  //stroke(0, 0, 10, 20);
  //fill(204, 102, 0);
  //rect(30, 20, 55, 35);
  
}

void mouseMoved() 
{
    //w tym momencie ruch myszki nie wywiera wpływu na program 
}
