/**
 * @file
 * @copyright 2021
 * @author zjdtmkhzt (https://github.com/zjdtmkhzt)
 * @license MIT
 */

import { Button, Flex, Section, TextArea } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// TODO: change usages to be theme-based rather than override color here
const paperColor = '#fdbfbfff'; // TODO: Pick a better red for sec

interface ContrabandPaperData {
  contrabandName: string;
  contrabandOrigin: string;
  contrabandValue: string;
  contrabandType: string;
  contrabandDetails: string;
  allContrabandValues: string[];
  crossed: string[];
}

export const ContrabandPaper = () => {
  const { act, data } = useBackend<ContrabandPaperData>();
  const {
    contrabandName,
    contrabandOrigin,
    contrabandValue,
    contrabandType,
    contrabandDetails,
    allContrabandValues,
    crossed,
  } = data;

  return (
    <Window
      title="Nanotrasen Contraband Assessment Form"
      theme="paper"
      width={500}
      height={600}
    >
      <Window.Content backgroundColor={paperColor}>
        <Section backgroundColor={paperColor}>
          <h3>Contraband Name</h3>
          <h4>{contrabandName === '' ? 'unknown' : contrabandName}</h4>
          <h3>Contraband Owner</h3>
          <TextArea
            value={contrabandOrigin}
            fluid
            height={2}
            onBlur={(x) => act('origin', { newOrigin: x })}
            backgroundColor={paperColor}
          />
          <h3>Contraband Level</h3>
          <Flex direction={'column'} wrap={'wrap'} height={3}>
            {allContrabandValues.map((x) => (
              <Flex.Item
                key={x}
                onClick={(e, value) => act('value', { newValue: x })}
              >
                <Button.Checkbox checked={contrabandValue === x} />
                <span>{crossed.includes(x) ? <s>{x}</s> : x}</span>
              </Flex.Item>
            ))}
          </Flex>
          <h3>Contraband Type</h3>
          <TextArea
            value={contrabandType}
            fluid
            height={5}
            onBlur={(x) => act('type', { newType: x })}
            backgroundColor={paperColor}
          />
          <h3>Additional Information</h3>
          <TextArea
            value={contrabandDetails}
            fluid
            height={10}
            onBlur={(x) => act('detail', { newDetail: x })}
            backgroundColor={paperColor}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

// TODO Add contraband level colors (below is from artifacts, ignore)
// const getArtifactSizeColor = (size: number): string => {
//   switch (size) {
//     case 3: // ARTIFACT_SIZE_LARGE
//       return '#c9acac';
//     case 2: // ARTIFACT_SIZE_MEDIUM
//       return '#ccc6b0';
//     case 1: // ARTIFACT_SIZE_TINY
//       return '#adc2d3';
//     default:
//       return 'lightgray';
//   }
// };
