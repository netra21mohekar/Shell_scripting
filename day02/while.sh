
#!/bin/bash
num=0
while [[ $((num%2))==0 && $num -le 10 ]]
do
        echo $num
        num=$((num+2))  # Increment by 2 to keep even numbers
done
