#!/bin/bash
# Author : Piotr Kolasinski (s193275@student.pg.edu.pl)
# Created on : 2023
# Last Modified By : Piotr Kolasinski (s193275@student.pg.edu.pl)
# Last Modifien On :02.06.2023
# Version          : wersja
#
# Description      :
# Aplikacja do edycji i przeksztalcania obrazow.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

pomoc() {
zenity --info --title "ImageWizard" --height 300 --width 300 \
--text "Aplikacja do edycji i przeksztalcania obrazow."
}

wersja() {
zenity --info --title "ImageWizard" --text "Linux Fedora \nAutor: Piotr Kolasinski" --height 200 --width 250
}

while getopts "hv" OPT; do
case $OPT in
h) pomoc;;
v) wersja;;
*) echo "Nieznana opcja";;
esac
done

drawOnImage() {
    if [ -z "$IMAGE" ]; then
        zenity --info --text "No photo loaded"
        return
    fi

    DRAW=$(zenity --list --column "Draw Shape" \
        "1. Draw Line" \
        "2. Draw Rectangle" \
        "3. Draw Circle" \
        "4. Draw Triangle"
    )
    
    OUTPUT_FILE="${CATALOG%.*}_drawn.png"

    case "$DRAW" in
        "1. Draw Line")
            # Prompt for line coordinates
            X1=$(zenity --entry --title "Draw Line" --text "Enter X-coordinate of the starting point:")
            Y1=$(zenity --entry --title "Draw Line" --text "Enter Y-coordinate of the starting point:")
            X2=$(zenity --entry --title "Draw Line" --text "Enter X-coordinate of the ending point:")
            Y2=$(zenity --entry --title "Draw Line" --text "Enter Y-coordinate of the ending point:")
            color=$(zenity --entry --title "Draw Line" --text "Enter color of the line:")
            width=$(zenity --entry --title "Draw Line" --text "Enter width of the line:")
            convert "$IMAGE" -stroke "$color" -strokewidth "$width" -draw "line $X1,$Y1 $X2,$Y2" "$OUTPUT_FILE"
            ;;
        "2. Draw Rectangle")
            # Prompt for rectangle coordinates and dimensions
            X=$(zenity --entry --title "Draw Rectangle" --text "Enter X-coordinate of the top-left corner:")
            Y=$(zenity --entry --title "Draw Rectangle" --text "Enter Y-coordinate of the top-left corner:")
            WIDTH=$(zenity --entry --title "Draw Rectangle" --text "Enter width of the rectangle:")
            HEIGHT=$(zenity --entry --title "Draw Rectangle" --text "Enter height of the rectangle:")
            color=$(zenity --entry --title "Draw Rectangle" --text "Enter color of the figure:")
            width=$(zenity --entry --title "Draw Rectangle" --text "Enter width of the figure:")
            filling=$(zenity --entry --title "Draw Rectangle" --text "Enter color filling of the figure (none - transparent:")
            convert "$IMAGE" -stroke "$color" -strokewidth "$width" -fill "$filling" -draw "rectangle $X,$Y $((X+WIDTH)),$((Y+HEIGHT))" "$OUTPUT_FILE"
            ;;
        "3. Draw Circle")
            X=$(zenity --entry --title "Draw Circle" --text "Enter X-coordinate of the center point:")
            Y=$(zenity --entry --title "Draw Circle" --text "Enter Y-coordinate of the center point:")
            RADIUS=$(zenity --entry --title "Draw Circle" --text "Enter radius of the circle:")
            color=$(zenity --entry --title "Draw Circle" --text "Enter color of the figure:")
            width=$(zenity --entry --title "Draw Circle" --text "Enter width of the figure:")
            filling=$(zenity --entry --title "Draw Rectangle" --text "Enter color filling of the figure (none - transparent:")
            convert "$IMAGE" -stroke "$color" -strokewidth "$width" -fill "$filling" -draw "ellipse $X,$Y $((X+RADIUS)),$((Y+RADIUS)) 0,360" "$OUTPUT_FILE"
            ;;
        "4. Draw Triangle")
            # Prompt for triangle coordinates
            X1=$(zenity --entry --title "Draw Triangle" --text "Enter X-coordinate of the first point:")
            Y1=$(zenity --entry --title "Draw Triangle" --text "Enter Y-coordinate of the first point:")
            X2=$(zenity --entry --title "Draw Triangle" --text "Enter X-coordinate of the second point:")
            Y2=$(zenity --entry --title "Draw Triangle" --text "Enter Y-coordinate of the second point:")
            X3=$(zenity --entry --title "Draw Triangle" --text "Enter X-coordinate of the third point:")
            Y3=$(zenity --entry --title "Draw Triangle" --text "Enter Y-coordinate of the third point:")
            color=$(zenity --entry --title "Draw Triangle" --text "Enter color of the figure:")
            width=$(zenity --entry --title "Draw Triangle" --text "Enter width of the figure:")
            filling=$(zenity --entry --title "Draw Triangle" --text "Enter color filling of the figure (none - transparent:")
            convert "$IMAGE" -stroke "$color" -strokewidth "$width" -fill "$filling" -draw "polygon $X1,$Y1 $X2,$Y2 $X3,$Y3" "$OUTPUT_FILE"
            ;;
        *)
            return
            ;;
    esac
}

installImageMagick() {
    if ! command -v convert &> /dev/null; then
        sudo dnf install ImageMagick
    else
        echo "ImageMagick is already installed."
    fi
}

cropImage() {
    WIDTH=$(zenity --entry --title "Crop Image" --text "Enter the desired width:")
    HEIGHT=$(zenity --entry --title "Crop Image" --text "Enter the desired height:")
    X=$(zenity --entry --title "Crop Image" --text "Enter the X-coordinate of the top-left corner:")
    Y=$(zenity --entry --title "Crop Image" --text "Enter the Y-coordinate of the top-left corner:")
    
    convert "$CATALOG" -crop "${WIDTH}x${HEIGHT}+${X}+${Y}" edited.png
    echo "Image cropped successfully."
}

composeImages() {
    COMPOSED_FILES=$(zenity --file-selection --title "Choose images to compose:" --multiple --separator='|')

    if [ -z "$COMPOSED_FILES" ]; then
        echo "No images selected."
        return
    fi

    IFS='|' read -ra FILE_ARRAY <<< "$COMPOSED_FILES"

    COMPOSED_MODE=$(zenity --list --column="Compose Mode" "1. Horizontal Composition" "2. Vertical Composition" --height 200 --width 250)

    case "$COMPOSED_MODE" in
        "1. Horizontal Composition")
            convert "${FILE_ARRAY[@]}" +append composed.png
            ;;
        "2. Vertical Composition")
            convert "${FILE_ARRAY[@]}" -append composed.png
            ;;
    esac
    echo "Images composed successfully."
}

applyArtisticFilter() {
    FILTER=$(zenity --list --title "Artistic Filters" --text "Choose an artistic filter:" --column "Filter" \
        "Oil Painting" \
        "Sketch" \
        "Watercolor" \
        "Vintage")

    case "$FILTER" in
        "Oil Painting")
            convert "$CATALOG" -paint "$((RANDOM%5+1))" edited.png
            ;;
        "Sketch")
            convert "$CATALOG" -sketch "$((RANDOM%2+1))x0" edited.png
            ;;
       "Watercolor")
    WIDTH=$(convert "$CATALOG" -format "%[fx:w]" info:)
    
    convert "$CATALOG" \
        \( +clone -colorspace Gray -auto-level \) \
        \( -clone 0 -blur "0x$(($WIDTH/100))" \) \
        -compose blend -define compose:args="10,90" -composite \
        -colorspace sRGB \
        -channel R -level 28% \
        -channel G -level 20% \
        edited.png
    ;;
        "Vintage")
            convert "$CATALOG" -sepia-tone "80%" -channel R -level "33%" -channel B -level "33%" edited.png
            ;;
        *)
            echo "Invalid filter selection."
            ;;
    esac
}

transformationMenu(){				#main menu to transform
	B=0
	while [[ $B != 9 ]]; do
		menu1="1. Scale the image"
		menu2="2. Convert image into black-white"
		menu3="3. Convert image into negative"
		menu4="4. Add border to the image"
		menu5="5. Rotate the image"
		menu6="6. Add watermark."
		menu7="7. Adjust image color"
		menu8="8. Apply artistic filter"
		menu9="10. Go back"
		TRANSFORM=("$menu1" "$menu2" "$menu3" "$menu4" "$menu5" "$menu6" "$menu7" "$menu8" "$menu9")
		B=$(zenity --list --column=TRANSFORM "${TRANSFORM[@]}" --height 300 --width 300)

		case "$B" in
			$menu1)		
				menuSCALE1="1. Scale in %"
				menuSCALE2="2. Resize to specified size"
				MENU_SCALE=("$menuSCALE1" "$menuSCALE2")
				C=$(zenity --list --column=MENU_SCALE "${MENU_SCALE[@]}" --height 250)

				case "$C" in
					$menuSCALE1)	
						SCALE=$(zenity --entry --title "Scaling" --text "Type in scale in %:")
						convert $CATALOG -resize $SCALE edited.png
						;;
					$menuSCALE2)		
						HEIGHT=$(zenity --entry --title "Scaling" --text "Type in height of photo:")
						convert $CATALOG -resize $HEIGHTx$HEIGHT edited.png
						;;
				esac
				;;
			$menu2)		
				convert $CATALOG -colorspace Gray edited.png
				;;
			$menu3)		
				convert -negate $CATALOG edited.png
				;;
			$menu4)		
				COLOR=$(zenity --entry --title "Choose color of border" --text "Type in color of border (blue, red, white, etc.):")
				BORDERSIZE=$(zenity --entry --title "Choose width of border" --text "Type in width of border in pixels:")
				convert -bordercolor $COLOR -border $BORDERSIZE $CATALOG edited.png
				;;
			$menu5)
				ROTATE=$(zenity --entry --title "Rotate" --text "Type in degrees to rotate the image (e.g., 90, -180, etc.):")
                		convert "$CATALOG" -rotate "$ROTATE" edited.png
                		;;
                	$menu6)
                		WATERMARK_TEXT=$(zenity --entry --title "Watermark" --text "Type in the text for watermark:")
                		WATERMARK_COLOR=$(zenity --entry --title "Watermark" --text "Type in the color for watermark (e.g., red, blue, #FF0000)")
                		convert -pointsize 300 -fill "$WATERMARK_COLOR" -gravity center -draw "text 0,0 '$WATERMARK_TEXT'" "$CATALOG" edited.png
                		;;
                	$menu7)
				menuCOLOR1="1. Adjust brightness"
				menuCOLOR2="2. Adjust contrast"
				menuCOLOR3="3. Adjust saturation"
				MENU_COLOR=("$menuCOLOR1" "$menuCOLOR2" "$menuCOLOR3")
				D=$(zenity --list --column=MENU_COLOR "${MENU_COLOR[@]}" --height 250)

				case "$D" in
				    $menuCOLOR1)       
				        BRIGHTNESS=$(zenity --entry --title "Brightness" --text "Type in the brightness level (-100 to 100):")
				        convert "$CATALOG" -brightness-contrast "${BRIGHTNESS}x0" edited.png
				        ;;
				    $menuCOLOR2)      
				        CONTRAST=$(zenity --entry --title "Contrast" --text "Type in the contrast level (-100 to 100):")
				        convert "$CATALOG" -brightness-contrast "0x${CONTRAST}" edited.png
				        ;;
				    $menuCOLOR3)      
				        SATURATION=$(zenity --entry --title "Saturation" --text "Type in the saturation level (-100 to 100):")
				        convert "$CATALOG" -modulate "100,${SATURATION},100" edited.png
				        ;;
				esac
				;;
			$menu8)
				applyArtisticFilter
				;;
			$menu9)		#exit from the menu
				B=9
				;;
		esac
	done
}

subMenu(){
	case "$A" in
		$option1)			
			installImageMagick
			;;
		$option2)			
			IMAGE=$(zenity --entry --title "Choose photo" --text "Type in name of image you want to edit:")
			if [ -z $IMAGE ]; then
				IMAGE=""
			else
				CATALOG=$(find -name $IMAGE)
			fi
			;;
		$option3)			
			if [ -z $IMAGE ]; then
				zenity --info --text="No photo loaded"
			else
				transformationMenu
			fi
			;;
		$option4)			
			if [ -z $IMAGE ]; then
				zenity --info --text="No photo loaded"
			else
				NEW_TYPE=$(zenity --entry --title "New type" --text "Type in name and type of your new file:")
				convert $CATALOG $NEW_TYPE
			fi
			;;
		$option5)			
			if [ -z $IMAGE ]; then
				zenity --info --text="No photo loaded"
			else
				identify -list color $CATALOG > color_list.txt
			fi
			;;
		$option6)			
			if [ -z $IMAGE ]; then
				zenity --info --text="No photo loaded"
			else
				CUT=${IMAGE%.*}
				convert $CUT*.* file.pdf
			fi
			;;
		$option7)
			cropImage
			;;
		$option8)
			composeImages
			;;

		$option9)			
			sudo apt-get --purge remove ImageMagick
			;;
		$option10)
			drawOnImage
			;;
		$option11)			
			A=9
			;;
	esac
}



generalMenu(){
	A=0
	while [[ $A != 9 ]]; do
		option1="1. Install software Imagemagick"
		option2="2. Choose image: $IMAGE"
		option3="3. Transform the image"
		option4="4. Convert the image type"
		option5="5. Get the color list of the image"
		option6="6. Convert the image into pdf file"
		option7="7. Crop the image"
		option8="8. Compose images"
		option9="9. Uninstall software Imagemagick"
		option10="10. Draw on image"
		option11="11. Exit"

		MENU=("$option1" "$option2" "$option3" "$option4" "$option5" "$option6" "$option7" "$option8" "$option9" "$option10" "$option11")
		A=$(zenity --list --column=MENU "${MENU[@]}" --height 400 --width 300)
		subMenu
	done
}


generalMenu
