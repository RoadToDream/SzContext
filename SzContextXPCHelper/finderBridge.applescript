

script finderBridge
	
	property parent : class "NSObject"
	

	to gotoPrevious()
    tell application "Finder"
        if front Finder window exists then
            set the_folder to (POSIX file "/Users/djw") as alias
            set target of front Finder window to the_folder
        else
            open the_folder
        end if
    end tell
	end gotoPrevious

end script
