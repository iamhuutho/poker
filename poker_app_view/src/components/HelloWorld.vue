<template>
  <div>
    <h1>Hello from the other side. Please enter your card data.</h1>
    <form @submit.prevent="handleSubmit">
      <div>
        <textarea v-on:@change="handleChange" id="data" v-model="formData" rows="5" placeholder="Enter your card data"></textarea>
      </div>
      <br>
      <button type="button" :disabled="!formData" @click="handleSubmit">Submit</button>
      <div v-if="submitted">The best poker hand is {{ response.card }}. Hand: {{ response.hand }}</div>
      <div v-if="isErr">{{ errMessage }}</div> 
     </form>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      formData: '',
      submitted: false, // Optional for loading state
      response: {
        card: "",
        hand: ""   
      },
      errMessage: "",
      isErr: false,
    };
  },
  methods: {
    async handleSubmit() {
      console.log(this.formData);
      const url = 'http://localhost:3000/api/v1/newpokers';
      try {
        const response = await axios.post(url, { message: this.formData });
        const flag = response.data.results.length > 0
        console.log("FLAG", flag)
        if (flag){
          const temp = response.data.results[0];
          this.response.card = temp.Card
          this.response.hand = temp.Hand
          this.submitted = true
          this.isErr = false
        }
      } catch (error) {
          const errList = error.response.data.errors
          this.errMessage = errList[0].message
          this.isErr = true
          this.submitted = false
      }
    },
  },
};
</script>


<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
