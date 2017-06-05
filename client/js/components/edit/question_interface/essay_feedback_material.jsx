import React, {Component} from 'react';
import Feedback from './feedback.jsx';
//import any other dependencies here.

export default class EssayAnswerFeedbackMaterial extends Component {
  constructor(props) {
    super(props);

    this.state = {};

    //rebindings for custom methods go here.
  }

  componentWillMount() {

  }

  render() {
    let question = this.props.question;

    //place JSX between the parens!
    return (
      <div>
        <Feedback
          style={{display: "block", width: "100%", marginBottom: "10px"}}
          index={-1}
          feedback={this.props.feedback.general_fb}
          onChange={this.props.handleFeedbackChange}
        />
      </div>
    );
  }

  componentWillUnmount() {

  }

  //========================================================================
  // PLACE CUSTOM METHODS AND HANDLERS BELOW HERE
  //========================================================================
}//end EssayAnswerFeedbackMaterial class

EssayAnswerFeedbackMaterial.propTypes = {
  answers: React.PropTypes.object,
  handleAnswerChange: React.PropTypes.func,
  handleFeedbackChange: React.PropTypes.func,
  handleCorrectChange: React.PropTypes.func,
  handleAddOption: React.PropTypes.func,
  handleAnswerRemoval: React.PropTypes.func
};

