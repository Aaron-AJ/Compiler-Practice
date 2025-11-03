#include <stdio.h>
#include <stdlib.h>

//perfect inputs <3
#define START_STATE 0
#define S1 1 //3
#define S2 2 //3-4
#define S3 3 //3-4-5
#define ACCEPT 4 //3-4-5-1

#define M1_2 5 //states if 1st input 3 is wrong (2 or 6)
#define M1_6 6

#define M2_1 7 // 3-1states if 2nd input (4) is wrong (1,5,7)
#define M2_5 8 // 3-5
#define M2_7 9 //3-7

#define M3_2 11//3-4-2 states if 3rd input(5) is wrong (2,4,6,8)
#define M3_4 12 // 3-4-4
#define M3_6 13 //3-4-6
#define M3_8 14 //3-4-8

#define M4_2 15 // 3-4-5-2states if 4th input (1) is wrong (2,4)
#define M4_4 16 // 3-4-5-4

#define M1_S2 16  //mistake at pos 1, got correct digit 4 so mistake -> m1_s2 -> m1_s3 with 1 input = s4/accept
#define M1_S3 17  

#define M2_S3 18  //mistake at pos 2, got correct digit 5
#define M3_S4 19  //mistake at pos 3, got correct digit 1

#define SE 20

int main(){
    int transition_table[21][10];

    for(int i=0;i<21;i++){
        for(int j=0;j<10;j++){
            transition_table[i][j] = SE; //default state is SE
            //printf("%d ",transition_table[i][j]);
        }
    }

    //filling transition table
    //from start with mistake at pos1
    transition_table[START_STATE][3] = S1;
    transition_table[START_STATE][2] = M1_2;
    transition_table[START_STATE][6] = M1_6;
    transition_table[M1_2][4] = M1_S2;
    transition_table[M1_6][4] = M1_S2;
    transition_table[M1_S2][5] = M1_S3;
    transition_table[M1_S3][1] = ACCEPT;

    //from S1 with mistake at pos2
    transition_table[S1][4] = S2;
    transition_table[S1][1] = M2_1;
    transition_table[S1][5] = M2_5;
    transition_table[S1][7] = M2_7;
    transition_table[M2_1][5] = M2_S3;
    transition_table[M2_5][5] = M2_S3;
    transition_table[M2_7][5] = M2_S3;
    transition_table[M2_S3][1] = ACCEPT;
    
    //from S2 with mistake at pos3
    transition_table[S2][5] = S3;
    transition_table[S2][2] = M3_2;
    transition_table[S2][4] = M3_4;
    transition_table[S2][6] = M3_6;
    transition_table[S2][8] = M3_8;
    transition_table[M3_2][1] = ACCEPT;
    transition_table[M3_4][1] = ACCEPT;
    transition_table[M3_6][1] = ACCEPT;
    transition_table[M3_8][1] = ACCEPT;

    //from S3 with mistake at pos4
    transition_table[S3][1] = ACCEPT;
    transition_table[S3][2] = M4_2;
    transition_table[S3][4] = M4_4;
    transition_table[M4_2][0] = ACCEPT;  
    transition_table[M4_4][0] = ACCEPT;

    int current_state = START_STATE;
    int input;
    int digit_count = 0;

    while(digit_count < 4){

        if (scanf("%d", &input) != 1) {
            printf("ERROR: input is not from the ALPHABET\n");
            return 1;
        }

        if (input < 0 || input > 9) {
            printf("ERROR: input is not from the ALPHABET\n");
            return 1;

    }

        current_state = transition_table[current_state][input];
        digit_count++;

        if(current_state == SE){
            printf("ERROR: an invalid PIN was entered, the door stays LOCKED\n");
            return 1;
        }

        if(digit_count == 4){
            if(current_state == ACCEPT  || current_state == M4_2 || current_state == M4_4){
                printf("ACCEPT: a valid PIN was entered, the door UNLOCKS\n");
                return 0;
            }
            else{
            printf("ERROR: an invalid PIN was entered, the door stays LOCKED\n");
            return 1;
            }
        }
    }
    return 0;
}