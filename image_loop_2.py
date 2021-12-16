import cv2
import pytesseract
import imutils
import os
import numpy
import re
import sys

pytesseract.pytesseract.tesseract_cmd=r'C:\Program Files\Tesseract-OCR\tesseract.exe'
 
imgPath= sys.argv[1]
         
img = cv2.imread(imgPath)
img = imutils.resize(img, width=1000)



############## Name ################

#first attemp 
#name_corp_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
#name_corp_img = cv2.adaptiveThreshold(name_corp_img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 85, 33)
name_corp_img=img[400:490,0:500]
#name_corp_img = cv2.resize(name_corp_img, None, fx=2, fy=2, interpolation=cv2.INTER_LINEAR)
boxes = pytesseract.image_to_data(name_corp_img)
ic_name=""
for x,b in enumerate(boxes.splitlines()):
	if x!=0:
		b = b.split()
	if len(b)==12:
		if int(b[2]) == 1:
			ic_name +=b[11] +" " 
         
#second attemp
##if re.search('[^a-zA-Z/._ \n]',ic_name):
##	print("false")
##	name_corp_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
##	name_corp_img = cv2.adaptiveThreshold(name_corp_img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 85, 23)
##	name_corp_img=name_corp_img[400:490,0:500]
##
##	boxes = pytesseract.image_to_data(name_corp_img)
##	ic_name=""
##	for x,b in enumerate(boxes.splitlines()):
##		if x!=0:
##			b = b.split()
##		if len(b)==12:
##			if int(b[2]) == 1:
##				ic_name +=b[11] +" "
				 
 ############## Name ################

############## IC No ################DONE 

ic_corp_img=img[140:200,0:400]
#ic_corp_img = cv2.cvtColor(ic_corp_img, cv2.COLOR_BGR2GRAY)
#ic_corp_img = cv2.adaptiveThreshold(ic_corp_img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 65, 23)
ic_text = pytesseract.image_to_string(ic_corp_img)
ic_text=re.sub('[^0-9-]', '',ic_text)

############## IC No ################

############## Address ################

addr_corp_img=img[470:1000,0:600]
#gray = cv2.cvtColor(addr_corp_img, cv2.COLOR_BGR2GRAY)

# Remove shadows, cf. https://stackoverflow.com/a/44752405/11089932
#dilated_img = cv2.dilate(gray, numpy.ones((7, 7), numpy.uint8))
#bg_img = cv2.medianBlur(dilated_img, 21)
#diff_img = 255 - cv2.absdiff(gray, bg_img)
#norm_img = cv2.normalize(diff_img, None, alpha=0, beta=255,norm_type=cv2.NORM_MINMAX, dtype=cv2.CV_8UC1)

#--- Otsu threshold ---
#th = cv2.threshold(norm_img, 0, 265, cv2.THRESH_BINARY | cv2.THRESH_OTSU)[1]
#cv2.imshow("norm_img", th)

# Tesseract
#custom_config = r'--oem 3 --psm 6'
addr_text = pytesseract.image_to_string(addr_corp_img)

# Remove all extra spaces
##def remove_all_extra_spaces(string):
##	return " ".join(string.split())
##addr_text = remove_all_extra_spaces(addr_text)
##addr_text = re.sub('[&.<>!@#$_:=~]', '', addr_text)

############## Address ################
  
full_details = ';'.join([ic_name, ic_text, addr_text])
print(full_details)
    
cv2.destroyAllWindows()
